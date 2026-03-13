import ComposableArchitecture
import SharedModels
import AppClients

@Reducer
public struct RequestFeature {

    @ObservableState
    public struct State: Equatable {
        public var request: APIRequest
        public var isLoading: Bool
        public var response: APIResponse?
        public var errorMessage: String?

        public init(request: APIRequest = APIRequest()) {
            self.request = request
            self.isLoading = false
        }
    }

    public enum Action {
        case methodChanged(HTTPMethod)
        case urlChanged(String)
        case headerAdded(key: String, value: String)
        case headerRemoved(key: String)
        case bodyChanged(String)
        case sendButtonTapped
        case responseReceived(Result<APIResponse, Error>)
    }

    @Dependency(\.urlSessionClient) var urlSessionClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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
