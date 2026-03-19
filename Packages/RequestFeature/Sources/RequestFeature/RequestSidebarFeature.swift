import AppClients
import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct RequestSidebarFeature {

    @ObservableState
    public struct State: Equatable {
        public var workspaces: [Workspace]
        public var selectedItem: SidebarItem?
        public var expandedFolders: Set<UUID>
        public var isLoading: Bool
        public var isShowingAddMenu: Bool

        public init(
            workspaces: [Workspace] = [],
            selectedItem: SidebarItem? = nil,
            expandedFolders: Set<UUID> = [],
            isLoading: Bool = false,
            isShowingAddMenu: Bool = false
        ) {
            self.workspaces = workspaces
            self.selectedItem = selectedItem
            self.expandedFolders = expandedFolders
            self.isLoading = isLoading
            self.isShowingAddMenu = isShowingAddMenu
        }
    }

    public enum Action {
        case onAppear
        case workspacesLoaded([Workspace])
        case createDefaultWorkspace
        case itemSelected(SidebarItem?)
        case folderToggled(UUID)
        case addButtonTapped
        case addMenuDismissed
        case addRequestButtonTapped
        case addFolderButtonTapped
        case folderAdded(UUID, Folder)
        case requestAdded(SidebarItem?, RequestItem)
    }

    @Dependency(\.coreData) var coreData

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let workspaces = try await coreData.fetchAPIWorkspaces()
                    await send(.workspacesLoaded(workspaces))
                }

            case let .workspacesLoaded(workspaces):
                state.isLoading = false
                if workspaces.isEmpty {
                    return .send(.createDefaultWorkspace)
                } else {
                    state.workspaces = workspaces
                    // Expand all folders by default
                    for workspace in workspaces {
                        for folder in workspace.folders {
                            state.expandedFolders.insert(folder.id)
                        }
                    }
                }
                return .none

            case .createDefaultWorkspace:
                let defaultWorkspace = Workspace(name: "My Workspace")
                return .run { send in
                    _ = try await coreData.saveAPIWorkspace(defaultWorkspace)
                    let workspaces = try await coreData.fetchAPIWorkspaces()
                    await send(.workspacesLoaded(workspaces))
                }

            case let .itemSelected(item):
                state.selectedItem = item
                return .none

            case let .folderToggled(folderID):
                if state.expandedFolders.contains(folderID) {
                    state.expandedFolders.remove(folderID)
                } else {
                    state.expandedFolders.insert(folderID)
                }
                return .none

            case .addButtonTapped:
                state.isShowingAddMenu.toggle()
                return .none

            case .addMenuDismissed:
                state.isShowingAddMenu = false
                return .none

            case .addRequestButtonTapped:
                state.isShowingAddMenu = false
                guard !state.workspaces.isEmpty else { return .none }

                let newRequest = RequestItem(name: "New Request", method: .get, url: "")

                // Determine parent based on selected item
                let parent: SidebarItem?
                if let selected = state.selectedItem {
                    switch selected {
                    case .folder:
                        parent = selected
                    case .request(let requestId):
                        // Find which folder or workspace contains this request
                        parent = findParent(for: requestId, in: state.workspaces)
                    }
                } else {
                    parent = nil // Will add to first workspace root
                }

                return .send(.requestAdded(parent, newRequest))

            case .addFolderButtonTapped:
                state.isShowingAddMenu = false
                guard !state.workspaces.isEmpty else { return .none }

                let newFolder = Folder(name: "New Folder")

                // Determine target workspace based on selected item
                let targetWorkspaceId: UUID
                if let selected = state.selectedItem {
                    targetWorkspaceId = findWorkspaceId(for: selected, in: state.workspaces)
                        ?? state.workspaces[0].id
                } else {
                    targetWorkspaceId = state.workspaces[0].id
                }

                return .send(.folderAdded(targetWorkspaceId, newFolder))

            case let .folderAdded(workspaceID, folder):
                return .run { send in
                    _ = try await coreData.saveAPIFolder(folder, workspaceID)
                    let workspaces = try await coreData.fetchAPIWorkspaces()
                    await send(.workspacesLoaded(workspaces))
                }

            case let .requestAdded(parent, request):
                return .run { send in
                    let folderId: UUID?
                    if let parent = parent {
                        switch parent {
                        case let .folder(folderID):
                            folderId = folderID
                        case .request:
                            folderId = nil
                        }
                    } else {
                        folderId = nil
                    }

                    _ = try await coreData.saveAPIRequest(request, folderId)
                    let workspaces = try await coreData.fetchAPIWorkspaces()
                    await send(.workspacesLoaded(workspaces))
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func findParent(for requestId: UUID, in workspaces: [Workspace]) -> SidebarItem? {
        for workspace in workspaces {
            // Check root requests
            if workspace.requests.contains(where: { $0.id == requestId }) {
                return nil // Root level, no folder parent
            }
            // Check folder requests
            for folder in workspace.folders {
                if folder.requests.contains(where: { $0.id == requestId }) {
                    return .folder(folder.id)
                }
            }
        }
        return nil
    }

    private func findWorkspaceId(for item: SidebarItem, in workspaces: [Workspace]) -> UUID? {
        switch item {
        case let .folder(folderId):
            for workspace in workspaces {
                if workspace.folders.contains(where: { $0.id == folderId }) {
                    return workspace.id
                }
            }
        case let .request(requestId):
            for workspace in workspaces {
                if workspace.requests.contains(where: { $0.id == requestId }) {
                    return workspace.id
                }
                for folder in workspace.folders {
                    if folder.requests.contains(where: { $0.id == requestId }) {
                        return workspace.id
                    }
                }
            }
        }
        return nil
    }
}
