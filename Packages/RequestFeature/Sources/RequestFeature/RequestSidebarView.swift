import ComposableArchitecture
import SharedModels
import SwiftUI

public struct RequestSidebarView: View {
    @Bindable var store: StoreOf<RequestSidebarFeature>
    @State private var activeTab: SidebarTab = .collections

    public init(store: StoreOf<RequestSidebarFeature>) {
        self.store = store
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Vertical icon strip
            SidebarIconStrip(activeTab: $activeTab)

            Divider()

            // Content panel
            sidebarContent(for: activeTab)
                .frame(minWidth: 200)
        }
        .frame(minWidth: 280)
    }

    @ViewBuilder
    private func sidebarContent(for tab: SidebarTab) -> some View {
        switch tab {
        case .collections:
            List(selection: Binding(
                get: { store.selectedItem },
                set: { store.send(.itemSelected($0)) }
            )) {
                ForEach(store.workspaces) { workspace in
                    ForEach(workspace.requests) { request in
                        RequestRow(request: request)
                            .tag(SidebarItem.request(request.id))
                            .contextMenu {
                                Button("Delete") { }
                            }
                    }

                    ForEach(workspace.folders) { folder in
                        FolderDisclosureGroup(
                            folder: folder,
                            isExpanded: store.expandedFolders.contains(folder.id),
                            selectedItem: store.selectedItem,
                            send: { store.send($0) }
                        )
                    }
                }
            }
            .listStyle(.sidebar)

        case .environments:
            List {
                Text("No environments yet")
                    .foregroundStyle(.secondary)
            }
            .listStyle(.sidebar)

        case .log:
            List {
                Text("No logs yet")
                    .foregroundStyle(.secondary)
            }
            .listStyle(.sidebar)
        }
    }
}
