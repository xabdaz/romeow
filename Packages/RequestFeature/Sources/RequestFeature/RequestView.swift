import ComposableArchitecture
import SharedModels
import SwiftUI

public struct RequestView: View {
    @Bindable var store: StoreOf<RequestFeature>

    public init(store: StoreOf<RequestFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView {
            RequestSidebarView(
                store: store.scope(state: \.sidebar, action: \.sidebar)
            )
        } detail: {
            RequestBuilderView(store: store)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Sidebar Toolbar
struct SidebarToolbar: View {
    let store: StoreOf<RequestSidebarFeature>

    var body: some View {
        HStack(spacing: 8) {
            Menu {
                Button(action: { store.send(.addWorkspaceButtonTapped) }) {
                    Label("New Workspace", systemImage: "briefcase")
                }

                Button(action: { store.send(.addFolderButtonTapped) }) {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }

                Divider()

                Button(action: { store.send(.addRequestButtonTapped) }) {
                    Label("New Request", systemImage: "plus")
                }
            } label: {
                Image(systemName: "plus")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.visible)
            .frame(width: 28, height: 22)

            Spacer()
        }
    }
}

// MARK: - Request Builder View
struct RequestBuilderView: View {
    let store: StoreOf<RequestFeature>

    var body: some View {
        VStack(spacing: 0) {
            // URL Bar
            URLBarView(store: store)

            Divider()

            // Request Body / Headers Section
            RequestConfigView(store: store)

            Divider()

            // Response Section
            ResponseView(store: store)
        }
        .frame(minWidth: 400)
    }
}

// MARK: - URL Bar
struct URLBarView: View {
    let store: StoreOf<RequestFeature>

    var body: some View {
        HStack(spacing: 12) {
            // Method Picker
            Picker("", selection: Binding(
                get: { store.request.method },
                set: { store.send(.methodChanged($0)) }
            )) {
                ForEach(HTTPMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)

            // URL TextField
            TextField("Enter URL", text: Binding(
                get: { store.request.url },
                set: { store.send(.urlChanged($0)) }
            ))
            .textFieldStyle(.roundedBorder)

            // Send Button
            Button(action: { store.send(.sendButtonTapped) }) {
                HStack(spacing: 4) {
                    if store.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text("Send")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .disabled(store.isLoading || store.request.url.isEmpty)
        }
        .padding()
    }
}

// MARK: - Request Config View
struct RequestConfigView: View {
    let store: StoreOf<RequestFeature>
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Body").tag(0)
                Text("Headers").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                RequestBodyView(store: store)
            } else {
                RequestHeadersView(store: store)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Request Body View
struct RequestBodyView: View {
    let store: StoreOf<RequestFeature>

    var body: some View {
        TextEditor(text: Binding(
            get: { store.request.body ?? "" },
            set: { store.send(.bodyChanged($0)) }
        ))
        .font(.system(.body, design: .monospaced))
        .padding(4)
    }
}

// MARK: - Request Headers View
struct RequestHeadersView: View {
    let store: StoreOf<RequestFeature>
    @State private var newKey = ""
    @State private var newValue = ""

    var body: some View {
        VStack(spacing: 0) {
            // Headers List
            List {
                ForEach(Array(store.request.headers.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                    HStack {
                        Text(key)
                            .font(.system(.body, design: .monospaced))
                        Spacer()
                        Text(value)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Button(action: { store.send(.headerRemoved(key: key)) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider()

            // Add Header
            HStack(spacing: 8) {
                TextField("Key", text: $newKey)
                    .textFieldStyle(.roundedBorder)
                TextField("Value", text: $newValue)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    guard !newKey.isEmpty else { return }
                    store.send(.headerAdded(key: newKey, value: newValue))
                    newKey = ""
                    newValue = ""
                }
                .disabled(newKey.isEmpty)
            }
            .padding()
        }
    }
}

// MARK: - Response View
struct ResponseView: View {
    let store: StoreOf<RequestFeature>
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Response Status Bar
            if let response = store.response {
                ResponseStatusBar(response: response)
            } else if let errorMessage = store.errorMessage {
                ErrorStatusBar(message: errorMessage)
            } else {
                EmptyResponseBar()
            }

            // Response Content
            if store.response != nil {
                Picker("", selection: $selectedTab) {
                    Text("Body").tag(0)
                    Text("Headers").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    ResponseBodyView(response: store.response)
                } else {
                    ResponseHeadersView(response: store.response)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Response Status Bar
struct ResponseStatusBar: View {
    let response: APIResponse

    var statusColor: Color {
        response.isSuccess ? .green : .red
    }

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text("\(response.statusCode)")
                    .fontWeight(.semibold)
            }

            Divider()
                .frame(height: 16)

            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                Text(String(format: "%.0f ms", response.duration * 1000))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.1))
    }
}

// MARK: - Error Status Bar
struct ErrorStatusBar: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.red.opacity(0.1))
    }
}

// MARK: - Empty Response Bar
struct EmptyResponseBar: View {
    var body: some View {
        HStack {
            Text("No response yet")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.05))
    }
}

// MARK: - Response Body View
struct ResponseBodyView: View {
    let response: APIResponse?

    var body: some View {
        ScrollView {
            Text(response?.bodyString ?? "")
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color(NSColor.textBackgroundColor))
    }
}

// MARK: - Response Headers View
struct ResponseHeadersView: View {
    let response: APIResponse?

    var body: some View {
        List {
            ForEach(Array((response?.headers ?? [:]).sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                HStack {
                    Text(key)
                        .font(.system(.body, design: .monospaced))
                    Spacer()
                    Text(value)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
