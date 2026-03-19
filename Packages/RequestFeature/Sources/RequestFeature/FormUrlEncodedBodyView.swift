import ComposableArchitecture
import SharedModels
import SwiftUI

struct FormUrlEncodedBodyView: View {
    let store: StoreOf<RequestFeature>
    @State private var newKey = ""
    @State private var newValue = ""

    private var fields: [FormField] {
        if case .formUrlEncoded(let fields) = store.request.bodyContent {
            return fields
        }
        return []
    }

    var body: some View {
        VStack(spacing: 0) {
            // Add Field Input
            HStack(spacing: 8) {
                TextField("Key", text: $newKey)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("formFieldKeyField")
                TextField("Value", text: $newValue)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("formFieldValueField")
                Button("Add") {
                    guard !newKey.isEmpty else { return }
                    store.send(.formFieldAdded(key: newKey, value: newValue))
                    newKey = ""
                    newValue = ""
                }
                .disabled(newKey.isEmpty)
                .accessibilityIdentifier("addFormFieldButton")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Fields List
            if fields.isEmpty {
                VStack {
                    Spacer()
                    Text("No form fields")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(fields) { field in
                        HStack {
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
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
