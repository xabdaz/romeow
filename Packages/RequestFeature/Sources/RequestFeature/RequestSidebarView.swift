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
        .onAppear {
            store.send(.onAppear)
        }
    }

    @ViewBuilder
    private func sidebarContent(for tab: SidebarTab) -> some View {
        switch tab {
        case .collections:
            VStack(spacing: 0) {
                // Header with add button
                HStack {
                    Text("Collections")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .popover(
                        isPresented: Binding(
                            get: { store.isShowingAddMenu },
                            set: { isPresented in
                                if !isPresented {
                                    store.send(.addMenuDismissed)
                                }
                            }
                        ),
                        arrowEdge: .trailing
                    ) {
                        AddMenuPopup(
                            onAddRequest: {
                                store.send(.addRequestButtonTapped)
                            },
                            onAddFolder: {
                                store.send(.addFolderButtonTapped)
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                Divider()

                if store.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                    Spacer()
                } else if store.workspaces.isEmpty {
                    Spacer()
                    Text("No workspaces")
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    List(selection: Binding(
                        get: { store.selectedItem },
                        set: { store.send(.itemSelected($0)) }
                    )) {
                        ForEach(store.workspaces) { workspace in
                            Section(workspace.name) {
                                // Root requests
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
                                        isExpanded: store.expandedFolders.contains(folder.id),
                                        selectedItem: store.selectedItem,
                                        send: { store.send($0) }
                                    )
                                }
                            }
                        }
                    }
                    .listStyle(.sidebar)
                }
            }

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
