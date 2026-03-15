import ComposableArchitecture
import SharedModels
import SwiftUI

public struct RouteEditorSheet: View {
    @Bindable var store: StoreOf<MockServerFeature>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<MockServerFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: .init(
                        get: { store.routeFormState.name },
                        set: { store.send(.routeFormFieldChanged(.name($0))) }
                    ))

                    TextField("Path (e.g., /api/users)", text: .init(
                        get: { store.routeFormState.path },
                        set: { store.send(.routeFormFieldChanged(.path($0))) }
                    ))

                    Picker("Method", selection: .init(
                        get: { store.routeFormState.method },
                        set: { store.send(.routeFormFieldChanged(.method($0))) }
                    )) {
                        ForEach(HTTPMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                }

                Section("Response") {
                    TextField("Status Code", text: .init(
                        get: { store.routeFormState.statusCode },
                        set: { store.send(.routeFormFieldChanged(.statusCode($0))) }
                    ))
                    .textFieldStyle(.roundedBorder)

                    TextField("Headers (JSON)", text: .init(
                        get: { store.routeFormState.responseHeaders },
                        set: { store.send(.routeFormFieldChanged(.responseHeaders($0))) }
                    ), axis: .vertical)
                    .lineLimit(3...6)

                    TextField("Response Body", text: .init(
                        get: { store.routeFormState.responseBody },
                        set: { store.send(.routeFormFieldChanged(.responseBody($0))) }
                    ), axis: .vertical)
                    .lineLimit(5...20)
                    .font(.system(.body, design: .monospaced))
                }

                Section {
                    Toggle("Enabled", isOn: .init(
                        get: { store.routeFormState.isEnabled },
                        set: { store.send(.routeFormFieldChanged(.isEnabled($0))) }
                    ))
                }
            }
            .formStyle(.grouped)
            .navigationTitle(store.routeFormState.id == nil ? "New Route" : "Edit Route")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.routeEditorSheetDismissed)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.saveRouteTapped)
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 600)
    }
}
