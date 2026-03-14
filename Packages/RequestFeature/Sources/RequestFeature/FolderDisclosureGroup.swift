import ComposableArchitecture
import SharedModels
import SwiftUI

struct FolderDisclosureGroup: View {
    let folder: Folder
    let isExpanded: Bool
    let selectedItem: SidebarItem?
    let send: (RequestSidebarFeature.Action) -> Void

    var body: some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { isExpanded },
                set: { _ in send(.folderToggled(folder.id)) }
            )
        ) {
            ForEach(folder.requests) { request in
                RequestRow(request: request)
                    .tag(SidebarItem.request(request.id))
                    .padding(.leading, 16)
                    .contextMenu {
                        Button("Delete") { }
                    }
            }
        } label: {
            FolderLabel(folder: folder)
                .tag(SidebarItem.folder(folder.id))
                .contentShape(Rectangle())
                .onTapGesture {
                    send(.itemSelected(.folder(folder.id)))
                }
        }
    }
}
