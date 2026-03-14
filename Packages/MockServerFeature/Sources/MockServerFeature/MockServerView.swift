import ComposableArchitecture
import SwiftUI

public struct MockServerView: View {
    let store: StoreOf<MockServerFeature>

    public init(store: StoreOf<MockServerFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView {
            // Sidebar - placeholder untuk konsistensi dengan RequestView
            MockServerSidebarView()
        } detail: {
            MockServerDetailView(store: store)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Sidebar View
struct MockServerSidebarView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Mock Server")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            // Routes List
            List {
                Section("Routes") {
                    HStack {
                        Text("GET")
                            .font(.system(.caption, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
                            .foregroundStyle(.blue)
                        Text("/health")
                            .font(.system(.body, design: .monospaced))
                        Spacer()
                    }
                }
            }
            .listStyle(.sidebar)

            Spacer()
        }
        .frame(minWidth: 200)
    }
}

// MARK: - Detail View
struct MockServerDetailView: View {
    let store: StoreOf<MockServerFeature>

    var body: some View {
        VStack(spacing: 24) {
            // Status indicator
            serverStatusBadge

            // Server URL info
            if store.isRunning {
                serverURLInfo
            }

            // Start / Stop button
            Button {
                store.send(store.isRunning ? .stopButtonTapped : .startButtonTapped)
            } label: {
                Label(
                    store.isRunning ? "Stop Server" : "Start Server",
                    systemImage: store.isRunning ? "stop.circle.fill" : "play.circle.fill"
                )
                .frame(minWidth: 160)
            }
            .buttonStyle(.borderedProminent)
            .tint(store.isRunning ? .red : .green)
            .controlSize(.large)

            // Error message
            if let error = store.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Divider()

            // Default routes info
            defaultRoutesInfo
        }
        .padding(32)
        .frame(minWidth: 360)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: { store.send(.featureSwitcherTapped) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "server.rack")
                        Text("Mock Server")
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Subviews

    private var serverStatusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(store.isRunning ? Color.green : Color.secondary.opacity(0.4))
                .frame(width: 10, height: 10)
                .overlay {
                    if store.isRunning {
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 18, height: 18)
                    }
                }

            Text(store.isRunning ? "Running" : "Stopped")
                .font(.headline)
                .foregroundStyle(store.isRunning ? .primary : .secondary)
        }
    }

    private var serverURLInfo: some View {
        VStack(spacing: 4) {
            Text("Listening on")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("http://127.0.0.1:\(store.port)")
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }

    private var defaultRoutesInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Default Routes")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Text("GET")
                    .font(.system(.caption, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
                    .foregroundStyle(.blue)

                Text("/health")
                    .font(.system(.caption, design: .monospaced))

                Spacer()

                Text("200 OK")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MockServerView(
        store: Store(initialState: MockServerFeature.State()) {
            MockServerFeature()
        }
    )
}
