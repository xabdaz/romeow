import ComposableArchitecture
import SharedModels
import SwiftUI

struct FormUrlEncodedBodyView: View {
    let store: StoreOf<RequestFeature>

    private var fields: [FormField] {
        if case .formUrlEncoded(let fields) = store.request.bodyContent {
            return fields
        }
        return []
    }

    var body: some View {
        VStack(spacing: 0) {
            // Fields List - directly editable
            List {
                ForEach(fields) { field in
                    HStack(spacing: 8) {
                        TextField("Key", text: Binding(
                            get: { field.key },
                            set: { store.send(.formFieldUpdated(id: field.id, key: $0, value: field.value)) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))

                        TextField("Value", text: Binding(
                            get: { field.value },
                            set: { store.send(.formFieldUpdated(id: field.id, key: field.key, value: $0)) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)

                        Button(action: { store.send(.formFieldRemoved(id: field.id)) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }

                // Add Field Button sebagai row terakhir
                Button(action: {
                    store.send(.formFieldAdded(key: "", value: ""))
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("Add Field")
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("addFormFieldButton")
            }
            .listStyle(.plain)
        }
    }
}
