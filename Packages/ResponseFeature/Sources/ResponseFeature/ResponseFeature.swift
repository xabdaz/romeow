import ComposableArchitecture
import SharedModels

@Reducer
public struct ResponseFeature {

    @ObservableState
    public struct State: Equatable {
        public var response: APIResponse?
        public var selectedTab: Tab

        public enum Tab: Equatable {
            case body, headers, info
        }

        public init(response: APIResponse? = nil) {
            self.response = response
            self.selectedTab = .body
        }
    }

    public enum Action {
        case tabSelected(State.Tab)
        case responseUpdated(APIResponse?)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case let .responseUpdated(response):
                state.response = response
                return .none
            }
        }
    }
}
