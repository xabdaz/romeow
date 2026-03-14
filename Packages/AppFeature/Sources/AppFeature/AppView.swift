import ComposableArchitecture
import RequestFeature
import MockServerFeature
import SwiftUI

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Group {
                switch store.selectedSidebar {
                case .requestBuilder, .none:
                    // RequestView sudah punya NavigationSplitView dengan sidebar workspace
                    RequestView(store: store.scope(state: \.request, action: \.request))

                case .mockServer:
                    MockServerView(store: store.scope(state: \.mockServer, action: \.mockServer))
                }
            }
        }
    }
}
