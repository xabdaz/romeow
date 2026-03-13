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

        // Hardcoded default workspace dengan sample data
        public init() {
            // Sample folder dengan requests
            let sampleFolder1 = Folder(
                id: UUID(),
                name: "Authentication",
                requests: [
                    RequestItem(id: UUID(), name: "Login", method: .post, url: "/api/auth/login"),
                    RequestItem(id: UUID(), name: "Logout", method: .post, url: "/api/auth/logout"),
                    RequestItem(id: UUID(), name: "Refresh Token", method: .post, url: "/api/auth/refresh")
                ]
            )

            let sampleFolder2 = Folder(
                id: UUID(),
                name: "Users",
                requests: [
                    RequestItem(id: UUID(), name: "Get Users", method: .get, url: "/api/users"),
                    RequestItem(id: UUID(), name: "Create User", method: .post, url: "/api/users"),
                    RequestItem(id: UUID(), name: "Update User", method: .put, url: "/api/users/1")
                ]
            )

            // Sample requests di root workspace
            let rootRequests = [
                RequestItem(id: UUID(), name: "Health Check", method: .get, url: "/health"),
                RequestItem(id: UUID(), name: "Get Profile", method: .get, url: "/api/profile")
            ]

            let defaultWorkspace = Workspace(
                id: UUID(),
                name: "My Workspace",
                folders: [sampleFolder1, sampleFolder2],
                requests: rootRequests
            )

            self.workspaces = [defaultWorkspace]
            self.selectedItem = nil
            self.expandedFolders = Set([sampleFolder1.id, sampleFolder2.id])
        }
    }

    public enum Action {
        case itemSelected(SidebarItem?)
        case folderToggled(UUID)
        case addWorkspaceButtonTapped
        case addFolderButtonTapped
        case addRequestButtonTapped
        case folderAdded(UUID, Folder)  // (workspaceID, folder)
        case requestAdded(SidebarItem, RequestItem)  // (parent, request) - parent bisa folder atau workspace
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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

            case .addWorkspaceButtonTapped:
                // Coming soon - untuk sekarang tidak melakukan apa-apa
                return .none

            case .addFolderButtonTapped:
                // Add folder ke workspace pertama (hardcoded untuk sekarang)
                guard !state.workspaces.isEmpty else { return .none }
                let workspaceID = state.workspaces[0].id
                let newFolder = Folder(name: "New Folder")
                return .send(.folderAdded(workspaceID, newFolder))

            case .addRequestButtonTapped:
                // Add request ke workspace pertama (hardcoded untuk sekarang)
                guard !state.workspaces.isEmpty else { return .none }
                let workspaceID = state.workspaces[0].id
                let newRequest = RequestItem(name: "New Request")
                return .send(.requestAdded(.folder(workspaceID), newRequest))

            case let .folderAdded(workspaceID, folder):
                if let index = state.workspaces.firstIndex(where: { $0.id == workspaceID }) {
                    state.workspaces[index].folders.append(folder)
                    state.expandedFolders.insert(folder.id)
                }
                return .none

            case let .requestAdded(parent, request):
                switch parent {
                case let .folder(folderID):
                    // Add request ke folder
                    for workspaceIndex in state.workspaces.indices {
                        if let folderIndex = state.workspaces[workspaceIndex].folders.firstIndex(where: { $0.id == folderID }) {
                            state.workspaces[workspaceIndex].folders[folderIndex].requests.append(request)
                            break
                        }
                    }
                case let .request(workspaceID):
                    // Add request ke workspace root
                    if let index = state.workspaces.firstIndex(where: { $0.id == workspaceID }) {
                        state.workspaces[index].requests.append(request)
                    }
                }
                state.selectedItem = .request(request.id)
                return .none
            }
        }
    }
}
