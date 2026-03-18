import ComposableArchitecture
import SwiftUI

public struct CreateWorkspaceSheet: View {
    @Bindable var store: StoreOf<MockServerFeature>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<MockServerFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                TextField("Workspace Name", text: .init(
                    get: { store.workspaceFormName },
                    set: { store.send(.workspaceNameChanged($0)) }
                ))
                .accessibilityIdentifier("workspaceNameField")
            }
            .formStyle(.grouped)
            .navigationTitle("New Workspace")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.createWorkspaceSheetDismissed)
                    }
                    .accessibilityIdentifier("cancelWorkspaceButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.saveWorkspaceTapped)
                    }
                    .disabled(store.workspaceFormName.isEmpty)
                    .accessibilityIdentifier("saveWorkspaceButton")
                }
            }
        }
        .frame(minWidth: 300, minHeight: 150)
    }
}
