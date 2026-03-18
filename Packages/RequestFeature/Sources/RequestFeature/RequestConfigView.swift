import ComposableArchitecture
import SwiftUI

struct RequestConfigView: View {
    let store: StoreOf<RequestFeature>
    @State private var selectedTab: RequestConfigTab = .body

    var body: some View {
        VStack(spacing: 0) {
            RequestConfigTabBar(
                selectedTab: $selectedTab,
                headerCount: store.request.headers.count
            )

            Divider()

            switch selectedTab {
            case .headers:
                RequestHeadersView(store: store)
            case .body:
                RequestBodyView(store: store)
            case .scripts:
                ScriptsPlaceholderView()
            }
        }
        .frame(maxHeight: .infinity)
        .accessibilityIdentifier("requestConfigView")
    }
}

struct ScriptsPlaceholderView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Scripts")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Pre-request and test scripts coming soon")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
