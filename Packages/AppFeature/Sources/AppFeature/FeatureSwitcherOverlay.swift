import ComposableArchitecture
import SharedModels
import SwiftUI

public struct FeatureSwitcherOverlay: View {
    let store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Color.rmeSecondaryText.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    store.send(.featureSwitcherTapped)
                }

            VStack(spacing: 0) {
                FeatureSwitcherItem(
                    icon: "network",
                    title: "REST API",
                    subtitle: "Build and send HTTP requests",
                    isSelected: store.selectedSidebar == .requestBuilder,
                    onSelect: {
                        store.send(.featureSelected("REST API"))
                    }
                )

                Divider()

                FeatureSwitcherItem(
                    icon: "server.rack",
                    title: "Mock Server",
                    subtitle: "Run local mock API server",
                    isSelected: store.selectedSidebar == .mockServer,
                    onSelect: {
                        store.send(.featureSelected("Mock Server"))
                    }
                )
            }
            .frame(width: 280)
            .background(Color.rmeSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xxLarge))
            .shadow(color: Color.rmeSecondaryText.opacity(0.2), radius: 16, x: 0, y: 8)
        }
    }
}
