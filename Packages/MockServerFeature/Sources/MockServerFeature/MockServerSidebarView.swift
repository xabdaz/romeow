import ComposableArchitecture
import SwiftUI

public struct MockServerSidebarView: View {
    @Bindable var store: StoreOf<MockServerFeature>

    public init(store: StoreOf<MockServerFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Workspace picker section
            WorkspacePicker(store: store)

            Divider()

            // Routes list
            if store.selectedWorkspaceId != nil {
                List(selection: .init(
                    get: { store.selectedRouteId },
                    set: { store.send(.routeSelected($0)) }
                )) {
                    Section("Routes") {
                        ForEach(store.filteredRoutes) { route in
                            MockRouteRow(route: route)
                                .tag(route.id)
                                .contextMenu {
                                    Button("Edit") {
                                        store.send(.editRouteTapped(route.id))
                                    }
                                    Button("Delete") {
                                        store.send(.deleteRouteTapped(route.id))
                                    }
                                }
                        }
                    }
                }
                .listStyle(.sidebar)
                .accessibilityIdentifier("routesList")
            } else {
                ContentUnavailableView("Select a workspace", systemImage: "folder")
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(minWidth: 200)
        .toolbar {
            ToolbarItem {
                Button(action: { store.send(.createWorkspaceTapped) }) {
                    Image(systemName: "folder.badge.plus")
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("createWorkspaceButton")
            }
        }
        .sheet(isPresented: .init(
            get: { store.isCreateWorkspaceSheetPresented },
            set: { if !$0 { store.send(.createWorkspaceSheetDismissed) } }
        )) {
            CreateWorkspaceSheet(store: store)
        }
        .sheet(isPresented: .init(
            get: { store.isRouteEditorSheetPresented },
            set: { if !$0 { store.send(.routeEditorSheetDismissed) } }
        )) {
            RouteEditorSheet(store: store)
        }
    }
}
