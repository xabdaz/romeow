import ComposableArchitecture
import Foundation
import SharedModels
import AppClients

@Reducer
public struct MockServerFeature {

    @ObservableState
    public struct State: Equatable {
        public var routes: [MockRoute]
        public var port: Int
        public var isRunning: Bool
        public var errorMessage: String?

        public init(routes: [MockRoute] = [], port: Int = 8080) {
            self.routes = routes
            self.port = port
            self.isRunning = false
        }
    }

    public enum Action {
        case startButtonTapped
        case stopButtonTapped
        case portChanged(Int)
        case routeAdded(MockRoute)
        case routeRemoved(id: UUID)
        case routeUpdated(MockRoute)
        case serverStarted
        case serverStopped
        case serverFailed(String)
        case featureSwitcherTapped
    }

    @Dependency(\.mockServerClient) var mockServerClient

    private enum CancelID { case server }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                let port = state.port
                let routes = state.routes.filter(\.isEnabled)
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

            case let .routeAdded(route):
                state.routes.append(route)
                return .none

            case let .routeRemoved(id):
                state.routes.removeAll { $0.id == id }
                return .none

            case let .routeUpdated(route):
                if let index = state.routes.firstIndex(where: { $0.id == route.id }) {
                    state.routes[index] = route
                }
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

            case .featureSwitcherTapped:
                // Delegated to parent (AppFeature) to handle
                return .none
            }
        }
    }
}
