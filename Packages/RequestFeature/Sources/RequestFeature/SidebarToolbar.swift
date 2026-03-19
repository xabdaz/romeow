import ComposableArchitecture
import SwiftUI

struct SidebarToolbar: View {
    let store: StoreOf<RequestSidebarFeature>

    var body: some View {
        HStack(spacing: 8) {
            Menu {
                Button(action: { store.send(.addRequestButtonTapped) }) {
                    Label("New Request", systemImage: "plus")
                }

                Button(action: { store.send(.addFolderButtonTapped) }) {
                    Label("New Folder", systemImage: "folder.badge.plus")
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
