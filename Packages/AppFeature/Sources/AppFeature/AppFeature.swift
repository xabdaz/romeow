import ComposableArchitecture
import RequestFeature
import ResponseFeature
import MockServerFeature

@Reducer
public struct AppFeature {

    @ObservableState
    public struct State: Equatable {
        public var selectedSidebar: SidebarItem?
        public var isFeatureSwitcherVisible: Bool
        public var request: RequestFeature.State
        public var response: ResponseFeature.State
        public var mockServer: MockServerFeature.State

        public enum SidebarItem: Hashable {
            case requestBuilder
            case mockServer
        }

        public init() {
            self.selectedSidebar = .requestBuilder
            self.isFeatureSwitcherVisible = false
            self.request = RequestFeature.State()
            self.response = ResponseFeature.State()
            self.mockServer = MockServerFeature.State()
        }
    }

    public enum Action {
        case sidebarItemSelected(State.SidebarItem?)
        case featureSwitcherTapped
        case featureSelected(String)
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

            case .featureSwitcherTapped:
                state.isFeatureSwitcherVisible.toggle()
                return .none

            case let .featureSelected(featureTitle):
                state.isFeatureSwitcherVisible = false
                switch featureTitle {
                case "REST API":
                    state.selectedSidebar = .requestBuilder
                case "Mock Server":
                    state.selectedSidebar = .mockServer
                default:
                    break
                }
                return .none

            // Handle feature switcher tap from RequestFeature
            case .request(.featureSwitcherTapped):
                state.isFeatureSwitcherVisible.toggle()
                return .none

            // Handle feature switcher tap from MockServerFeature
            case .mockServer(.featureSwitcherTapped):
                state.isFeatureSwitcherVisible.toggle()
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
