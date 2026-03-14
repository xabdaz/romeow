import ComposableArchitecture
import SwiftUI

public struct RequestView: View {
    @Bindable var store: StoreOf<RequestFeature>

    public init(store: StoreOf<RequestFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView {
            RequestSidebarView(
                store: store.scope(state: \.sidebar, action: \.sidebar)
            )
        } detail: {
            RequestBuilderView(store: store)
        }
        .navigationSplitViewStyle(.balanced)
    }
}
