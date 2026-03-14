import ComposableArchitecture
import SharedModels
import SwiftUI

struct WorkspaceSection: View {
    let workspace: Workspace
    let expandedFolders: Set<UUID>
    let selectedItem: SidebarItem?
    let send: (RequestSidebarFeature.Action) -> Void

    var body: some View {
        // Root requests (requests yang langsung di workspace, bukan di folder)
        ForEach(workspace.requests) { request in
            RequestRow(request: request)
                .tag(SidebarItem.request(request.id))
                .contextMenu {
                    Button("Delete") { }
                }
        }

        // Folders
        ForEach(workspace.folders) { folder in
            FolderDisclosureGroup(
                folder: folder,
                isExpanded: expandedFolders.contains(folder.id),
                selectedItem: selectedItem,
                send: send
            )
        }
    }
}
