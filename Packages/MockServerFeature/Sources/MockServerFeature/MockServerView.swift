import ComposableArchitecture
import SwiftUI

public struct MockServerView: View {
    let store: StoreOf<MockServerFeature>

    public init(store: StoreOf<MockServerFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView {
            MockServerSidebarView(store: store)
        } detail: {
            MockServerDetailView(store: store)
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    MockServerView(
        store: Store(initialState: MockServerFeature.State()) {
            MockServerFeature()
        }
    )
}
