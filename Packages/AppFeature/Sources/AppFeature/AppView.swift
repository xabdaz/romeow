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
        NavigationSplitView {
            SidebarView(store: store)
        } detail: {
            DetailView(store: store)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        List(selection: Binding(
            get: { store.selectedSidebar },
            set: { store.send(.sidebarItemSelected($0)) }
        )) {
            Section("Features") {
                NavigationLink(value: AppFeature.State.SidebarItem.requestBuilder) {
                    Label("REST API", systemImage: "network")
                }

                NavigationLink(value: AppFeature.State.SidebarItem.mockServer) {
                    Label("Mock Server", systemImage: "server.rack")
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 180)
    }
}

// MARK: - Detail View
struct DetailView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        switch store.selectedSidebar {
        case .requestBuilder, .none:
            RequestView(store: store.scope(state: \.request, action: \.request))

        case .mockServer:
            MockServerView(store: store.scope(state: \.mockServer, action: \.mockServer))
        }
    }
}
