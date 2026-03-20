import ComposableArchitecture
import Foundation
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
        case headerUpdated(oldKey: String, newKey: String, value: String)
        case headerRemoved(key: String)
        case bodyTypeChanged(BodyType)
        case bodyContentChanged(BodyContent)
        case formFieldAdded(key: String, value: String)
        case formFieldUpdated(id: UUID, key: String, value: String)
        case formFieldRemoved(id: UUID)
        case sendButtonTapped
        case responseReceived(Result<APIResponse, Error>)
        case requestSelected(RequestItem)
        case delegate(Delegate)

        public enum Delegate {
            case featureSwitcherTapped
        }
    }

    @Dependency(\.urlSessionClient) var urlSessionClient

    public init() {}

    private func updateContentTypeHeader(state: inout State, bodyType: BodyType) {
        let contentType: String
        switch bodyType {
        case .none:
            contentType = ""
        case .json:
            contentType = "application/json"
        case .formUrlEncoded:
            contentType = "application/x-www-form-urlencoded"
        case .raw:
            // For raw, keep existing Content-Type if user set custom, otherwise default to text/plain
            if let existing = state.request.headers["Content-Type"], !existing.isEmpty {
                // Don't override if user has set a custom one
                return
            }
            contentType = "text/plain"
        }

        if contentType.isEmpty {
            state.request.headers.removeValue(forKey: "Content-Type")
        } else {
            state.request.headers["Content-Type"] = contentType
        }
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.sidebar, action: \.sidebar) {
            RequestSidebarFeature()
        }
        Reduce { state, action in
            switch action {
            case .sidebar:
                return .none

            case .delegate(.featureSwitcherTapped):
                // Delegated to parent (AppFeature) to handle
                return .none

            case let .requestSelected(requestItem):
                state.request = APIRequest(
                    id: requestItem.id,
                    name: requestItem.name,
                    method: requestItem.method,
                    url: requestItem.url
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

            case let .headerUpdated(oldKey, newKey, value):
                // Remove old key if it changed
                if oldKey != newKey {
                    state.request.headers.removeValue(forKey: oldKey)
                }
                // Set new key-value (only if key is not empty)
                if !newKey.isEmpty {
                    state.request.headers[newKey] = value
                }
                return .none

            case let .headerRemoved(key):
                state.request.headers.removeValue(forKey: key)
                return .none

            case let .bodyTypeChanged(bodyType):
                state.request.bodyType = bodyType
                // Auto-update Content-Type header
                updateContentTypeHeader(state: &state, bodyType: bodyType)
                // Reset body content when type changes
                switch bodyType {
                case .none:
                    state.request.bodyContent = .none
                case .json:
                    state.request.bodyContent = .json("")
                case .formUrlEncoded:
                    state.request.bodyContent = .formUrlEncoded([])
                case .raw:
                    state.request.bodyContent = .raw("", contentType: "text/plain")
                }
                return .none

            case let .bodyContentChanged(content):
                state.request.bodyContent = content
                return .none

            case let .formFieldAdded(key, value):
                var fields: [FormField] = []
                if case .formUrlEncoded(let existingFields) = state.request.bodyContent {
                    fields = existingFields
                }
                fields.append(FormField(key: key, value: value))
                state.request.bodyContent = .formUrlEncoded(fields)
                return .none

            case let .formFieldUpdated(id, key, value):
                guard case .formUrlEncoded(var fields) = state.request.bodyContent else {
                    return .none
                }
                if let index = fields.firstIndex(where: { $0.id == id }) {
                    fields[index].key = key
                    fields[index].value = value
                    state.request.bodyContent = .formUrlEncoded(fields)
                }
                return .none

            case let .formFieldRemoved(id):
                guard case .formUrlEncoded(var fields) = state.request.bodyContent else {
                    return .none
                }
                fields.removeAll { $0.id == id }
                state.request.bodyContent = .formUrlEncoded(fields)
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
