import ComposableArchitecture
import SwiftUI

public struct MockServerView: View {
    let store: StoreOf<MockServerFeature>

    public init(store: StoreOf<MockServerFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView {
            // Sidebar - placeholder untuk konsistensi dengan RequestView
            MockServerSidebarView()
        } detail: {
            MockServerDetailView(store: store)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    MockServerView(
        store: Store(initialState: MockServerFeature.State()) {
            MockServerFeature()
        }
    )
}
