import ComposableArchitecture
import SwiftUI

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
