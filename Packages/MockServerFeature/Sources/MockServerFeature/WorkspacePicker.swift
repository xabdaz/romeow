import ComposableArchitecture
import SwiftUI

public struct WorkspacePicker: View {
    @Bindable var store: StoreOf<MockServerFeature>

    public init(store: StoreOf<MockServerFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Workspace")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: { store.send(.createWorkspaceTapped) }) {
                    Image(systemName: "folder.badge.plus")
                }
                .buttonStyle(.borderless)

                if let selectedId = store.selectedWorkspaceId {
                    Button(action: { store.send(.deleteWorkspaceTapped(selectedId)) }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }

            Picker("", selection: .init(
                get: { store.selectedWorkspaceId },
                set: { store.send(.workspaceSelected($0)) }
            )) {
                Text("Select Workspace").tag(nil as UUID?)
                ForEach(store.workspaces) { workspace in
                    Text(workspace.name).tag(workspace.id as UUID?)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
    }
}
