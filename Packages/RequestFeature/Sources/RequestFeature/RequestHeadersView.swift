import ComposableArchitecture
import SwiftUI

struct RequestHeadersView: View {
    let store: StoreOf<RequestFeature>

    private var sortedHeaders: [(key: String, value: String)] {
        store.request.headers.sorted { $0.key < $1.key }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Headers List - directly editable
            List {
                ForEach(sortedHeaders, id: \.key) { header in
                    HStack(spacing: 8) {
                        TextField("Key", text: Binding(
                            get: { header.key },
                            set: { newKey in
                                store.send(.headerUpdated(
                                    oldKey: header.key,
                                    newKey: newKey,
                                    value: header.value
                                ))
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))

                        TextField("Value", text: Binding(
                            get: { header.value },
                            set: { newValue in
                                store.send(.headerUpdated(
                                    oldKey: header.key,
                                    newKey: header.key,
                                    value: newValue
                                ))
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)

                        Button(action: { store.send(.headerRemoved(key: header.key)) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }

                // Add Header Button sebagai row terakhir
                Button(action: {
                    store.send(.headerAdded(key: "", value: ""))
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("Add Header")
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("addHeaderButton")
            }
            .listStyle(.plain)
        }
    }
}
