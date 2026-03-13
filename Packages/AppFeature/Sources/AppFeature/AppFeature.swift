import ComposableArchitecture
import RequestFeature
import ResponseFeature
import MockServerFeature

@Reducer
public struct AppFeature {

    @ObservableState
    public struct State: Equatable {
        public var selectedSidebar: SidebarItem?
        public var request: RequestFeature.State
        public var response: ResponseFeature.State
        public var mockServer: MockServerFeature.State

        public enum SidebarItem: Hashable {
            case requestBuilder
            case mockServer
        }

        public init() {
            self.selectedSidebar = .requestBuilder
            self.request = RequestFeature.State()
            self.response = ResponseFeature.State()
            self.mockServer = MockServerFeature.State()
        }
    }

    public enum Action {
        case sidebarItemSelected(State.SidebarItem?)
        case request(RequestFeature.Action)
        case response(ResponseFeature.Action)
        case mockServer(MockServerFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.request, action: \.request) {
            RequestFeature()
        }
        Scope(state: \.response, action: \.response) {
            ResponseFeature()
        }
        Scope(state: \.mockServer, action: \.mockServer) {
            MockServerFeature()
        }
        Reduce { state, action in
            switch action {
            case let .sidebarItemSelected(item):
                state.selectedSidebar = item
                return .none

            // Response di-sync saat request selesai
            case let .request(.responseReceived(.success(apiResponse))):
                state.response.response = apiResponse
                return .none

            case .request, .response, .mockServer:
                return .none
            }
        }
    }
}
