import ComposableArchitecture
import Foundation
import SharedModels
import AppClients

@Reducer
public struct MockServerFeature {

    @ObservableState
    public struct State: Equatable {
        // Existing server state
        public var routes: [MockRoute]
        public var port: Int
        public var isRunning: Bool
        public var errorMessage: String?

        // NEW: Workspace state
        public var workspaces: [MockWorkspace]
        public var selectedWorkspaceId: UUID?
        public var selectedRouteId: UUID?

        // NEW: Sheet presentation state
        public var isCreateWorkspaceSheetPresented: Bool
        public var isRouteEditorSheetPresented: Bool
        public var workspaceFormName: String
        public var routeFormState: RouteFormState

        // NEW: Computed property untuk routes di workspace yang dipilih
        public var filteredRoutes: [MockRoute] {
            guard let workspaceId = selectedWorkspaceId else { return [] }
            return routes.filter { $0.workspaceId == workspaceId }
        }

        public init(
            routes: [MockRoute] = [],
            port: Int = 8080,
            workspaces: [MockWorkspace] = [],
            selectedWorkspaceId: UUID? = nil,
            selectedRouteId: UUID? = nil,
            isCreateWorkspaceSheetPresented: Bool = false,
            isRouteEditorSheetPresented: Bool = false,
            workspaceFormName: String = "",
            routeFormState: RouteFormState = RouteFormState()
        ) {
            self.routes = routes
            self.port = port
            self.isRunning = false
            self.workspaces = workspaces
            self.selectedWorkspaceId = selectedWorkspaceId
            self.selectedRouteId = selectedRouteId
            self.isCreateWorkspaceSheetPresented = isCreateWorkspaceSheetPresented
            self.isRouteEditorSheetPresented = isRouteEditorSheetPresented
            self.workspaceFormName = workspaceFormName
            self.routeFormState = routeFormState
        }
    }

    public struct RouteFormState: Equatable {
        public var id: UUID?  // nil untuk create, ada untuk edit
        public var name: String
        public var path: String
        public var method: HTTPMethod
        public var statusCode: String
        public var responseBody: String
        public var responseHeaders: String
        public var isEnabled: Bool

        public init(
            id: UUID? = nil,
            name: String = "",
            path: String = "/",
            method: HTTPMethod = .get,
            statusCode: String = "200",
            responseBody: String = "{}",
            responseHeaders: String = "{\"Content-Type\": \"application/json\"}",
            isEnabled: Bool = true
        ) {
            self.id = id
            self.name = name
            self.path = path
            self.method = method
            self.statusCode = statusCode
            self.responseBody = responseBody
            self.responseHeaders = responseHeaders
            self.isEnabled = isEnabled
        }
    }

    public enum Action {
        // Existing
        case startButtonTapped
        case stopButtonTapped
        case portChanged(Int)
        case serverStarted
        case serverStopped
        case serverFailed(String)

        // NEW: Lifecycle
        case onAppear
        case workspacesLoaded([MockWorkspace])
        case routesLoaded([MockRoute])

        // NEW: Selection
        case workspaceSelected(UUID?)
        case routeSelected(UUID?)

        // NEW: Workspace CRUD
        case createWorkspaceTapped
        case saveWorkspaceTapped
        case deleteWorkspaceTapped(UUID)
        case workspaceNameChanged(String)
        case createWorkspaceSheetDismissed

        // NEW: Route CRUD
        case createRouteTapped
        case editRouteTapped(UUID)
        case saveRouteTapped
        case deleteRouteTapped(UUID)
        case routeFormFieldChanged(RouteFormField)
        case routeEditorSheetDismissed

        // NEW: Persistence result
        case persistenceFailed(String)

        case delegate(Delegate)
        public enum Delegate {
            case featureSwitcherTapped
        }

        public enum RouteFormField {
            case name(String)
            case path(String)
            case method(HTTPMethod)
            case statusCode(String)
            case responseBody(String)
            case responseHeaders(String)
            case isEnabled(Bool)
        }
    }

    @Dependency(\.mockServerClient) var mockServerClient
    @Dependency(\.coreData) var coreData

    private enum CancelID { case server }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.workspacesLoaded(try coreData.fetchWorkspaces()))
                    await send(.routesLoaded(try coreData.fetchRoutes(nil)))
                } catch: { error, send in
                    await send(.persistenceFailed(error.localizedDescription))
                }

            case let .workspacesLoaded(workspaces):
                state.workspaces = workspaces
                // Auto-select first workspace if none selected
                if state.selectedWorkspaceId == nil, let first = workspaces.first {
                    state.selectedWorkspaceId = first.id
                }
                return .none

            case let .routesLoaded(routes):
                state.routes = routes
                return .none

            case let .workspaceSelected(id):
                state.selectedWorkspaceId = id
                state.selectedRouteId = nil
                return .none

            case let .routeSelected(id):
                state.selectedRouteId = id
                return .none

            // MARK: - Workspace CRUD

            case .createWorkspaceTapped:
                state.workspaceFormName = ""
                state.isCreateWorkspaceSheetPresented = true
                return .none

            case .saveWorkspaceTapped:
                let name = state.workspaceFormName
                guard !name.isEmpty else { return .none }

                let workspace = MockWorkspace(name: name)
                state.isCreateWorkspaceSheetPresented = false
                state.workspaceFormName = ""

                return .run { send in
                    let saved = try await coreData.saveWorkspace(workspace)
                    var workspaces = try await coreData.fetchWorkspaces()
                    await send(.workspacesLoaded(workspaces))
                    await send(.workspaceSelected(saved.id))
                } catch: { error, send in
                    await send(.persistenceFailed(error.localizedDescription))
                }

            case let .deleteWorkspaceTapped(id):
                return .run { send in
                    try await coreData.deleteWorkspace(id)
                    await send(.workspacesLoaded(try coreData.fetchWorkspaces()))
                    await send(.routesLoaded(try coreData.fetchRoutes(nil)))
                    await send(.workspaceSelected(nil))
                } catch: { error, send in
                    await send(.persistenceFailed(error.localizedDescription))
                }

            case let .workspaceNameChanged(name):
                state.workspaceFormName = name
                return .none

            case .createWorkspaceSheetDismissed:
                state.isCreateWorkspaceSheetPresented = false
                state.workspaceFormName = ""
                return .none

            // MARK: - Route CRUD

            case .createRouteTapped:
                guard state.selectedWorkspaceId != nil else { return .none }
                state.routeFormState = RouteFormState()
                state.isRouteEditorSheetPresented = true
                return .none

            case let .editRouteTapped(id):
                guard let route = state.routes.first(where: { $0.id == id }) else { return .none }
                state.routeFormState = RouteFormState(
                    id: route.id,
                    name: route.name,
                    path: route.path,
                    method: route.method,
                    statusCode: String(route.statusCode),
                    responseBody: route.responseBody,
                    responseHeaders: encodeHeaders(route.responseHeaders),
                    isEnabled: route.isEnabled
                )
                state.isRouteEditorSheetPresented = true
                return .none

            case .saveRouteTapped:
                guard let workspaceId = state.selectedWorkspaceId else { return .none }

                let form = state.routeFormState
                guard !form.name.isEmpty, !form.path.isEmpty else { return .none }

                guard let statusCode = Int(form.statusCode) else { return .none }

                let route = MockRoute(
                    id: form.id ?? UUID(),
                    workspaceId: workspaceId,
                    name: form.name,
                    method: form.method,
                    path: form.path,
                    statusCode: statusCode,
                    responseHeaders: decodeHeaders(form.responseHeaders),
                    responseBody: form.responseBody,
                    isEnabled: form.isEnabled
                )

                state.isRouteEditorSheetPresented = false
                state.routeFormState = RouteFormState()

                return .run { send in
                    _ = try await coreData.saveRoute(route)
                    await send(.routesLoaded(try coreData.fetchRoutes(nil)))
                } catch: { error, send in
                    await send(.persistenceFailed(error.localizedDescription))
                }

            case let .deleteRouteTapped(id):
                return .run { send in
                    try await coreData.deleteRoute(id)
                    await send(.routesLoaded(try coreData.fetchRoutes(nil)))
                    await send(.routeSelected(nil))
                } catch: { error, send in
                    await send(.persistenceFailed(error.localizedDescription))
                }

            case let .routeFormFieldChanged(field):
                switch field {
                case let .name(name):
                    state.routeFormState.name = name
                case let .path(path):
                    state.routeFormState.path = path
                case let .method(method):
                    state.routeFormState.method = method
                case let .statusCode(code):
                    state.routeFormState.statusCode = code
                case let .responseBody(body):
                    state.routeFormState.responseBody = body
                case let .responseHeaders(headers):
                    state.routeFormState.responseHeaders = headers
                case let .isEnabled(enabled):
                    state.routeFormState.isEnabled = enabled
                }
                return .none

            case .routeEditorSheetDismissed:
                state.isRouteEditorSheetPresented = false
                state.routeFormState = RouteFormState()
                return .none

            // MARK: - Server Operations

            case .startButtonTapped:
                let port = state.port
                // Only use routes from selected workspace that are enabled
                let routes = state.filteredRoutes.filter(\.isEnabled)
                return .run { send in
                    do {
                        try await mockServerClient.start(port, routes)
                        await send(.serverStarted)
                    } catch {
                        await send(.serverFailed(error.localizedDescription))
                    }
                }
                .cancellable(id: CancelID.server, cancelInFlight: true)

            case .stopButtonTapped:
                return .run { send in
                    do {
                        try await mockServerClient.stop()
                        await send(.serverStopped)
                    } catch {
                        await send(.serverFailed(error.localizedDescription))
                    }
                }
                .cancellable(id: CancelID.server, cancelInFlight: true)

            case let .portChanged(port):
                state.port = port
                return .none

            case .serverStarted:
                state.isRunning = true
                state.errorMessage = nil
                return .none

            case .serverStopped:
                state.isRunning = false
                return .none

            case let .serverFailed(message):
                state.isRunning = false
                state.errorMessage = message
                return .none

            case let .persistenceFailed(message):
                state.errorMessage = message
                return .none

            case .delegate(.featureSwitcherTapped):
                return .none
            }
        }
    }
}

// MARK: - Helpers

private func encodeHeaders(_ headers: [String: String]) -> String {
    guard let data = try? JSONEncoder().encode(headers),
          let string = String(data: data, encoding: .utf8) else {
        return "{}"
    }
    return string
}

private func decodeHeaders(_ string: String) -> [String: String] {
    guard let data = string.data(using: .utf8),
          let headers = try? JSONDecoder().decode([String: String].self, from: data) else {
        return [:]
    }
    return headers
}
