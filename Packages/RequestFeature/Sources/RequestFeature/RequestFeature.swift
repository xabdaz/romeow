import ComposableArchitecture
import SharedModels
import AppClients

@Reducer
public struct RequestFeature {

    @ObservableState
    public struct State: Equatable {
        public var sidebar: RequestSidebarFeature.State
        public var request: APIRequest
        public var isLoading: Bool
        public var response: APIResponse?
        public var errorMessage: String?

        public init(
            sidebar: RequestSidebarFeature.State = RequestSidebarFeature.State(),
            request: APIRequest = APIRequest()
        ) {
            self.sidebar = sidebar
            self.request = request
            self.isLoading = false
        }
    }

    public enum Action {
        case sidebar(RequestSidebarFeature.Action)
        case methodChanged(HTTPMethod)
        case urlChanged(String)
        case headerAdded(key: String, value: String)
        case headerRemoved(key: String)
        case bodyChanged(String)
        case sendButtonTapped
        case responseReceived(Result<APIResponse, Error>)
        case requestSelected(RequestItem)
        case featureSwitcherTapped
    }

    @Dependency(\.urlSessionClient) var urlSessionClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.sidebar, action: \.sidebar) {
            RequestSidebarFeature()
        }
        Reduce { state, action in
            switch action {
            case .sidebar:
                return .none

            case .featureSwitcherTapped:
                // Delegated to parent (AppFeature) to handle
                return .none

            case let .requestSelected(requestItem):
                state.request = APIRequest(
                    id: requestItem.id,
                    name: requestItem.name,
                    method: requestItem.method,
                    url: requestItem.url,
                    headers: [:],
                    body: nil
                )
                return .none

            case let .methodChanged(method):
                state.request.method = method
                return .none

            case let .urlChanged(url):
                state.request.url = url
                return .none

            case let .headerAdded(key, value):
                state.request.headers[key] = value
                return .none

            case let .headerRemoved(key):
                state.request.headers.removeValue(forKey: key)
                return .none

            case let .bodyChanged(body):
                state.request.body = body
                return .none

            case .sendButtonTapped:
                state.isLoading = true
                state.errorMessage = nil
                let request = state.request
                return .run { send in
                    await send(.responseReceived(
                        Result { try await urlSessionClient.send(request) }
                    ))
                }

            case let .responseReceived(.success(response)):
                state.isLoading = false
                state.response = response
                return .none

            case let .responseReceived(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
