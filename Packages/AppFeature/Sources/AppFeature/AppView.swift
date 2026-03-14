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

            // Feature Switcher Overlay
            if store.isFeatureSwitcherVisible {
                FeatureSwitcherOverlay(store: store)
            }
        }
    }
}

// MARK: - Feature Switcher Overlay
struct FeatureSwitcherOverlay: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        ZStack {
            // Background overlay (tap to dismiss)
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    store.send(.featureSwitcherTapped)
                }

            // Feature switcher menu
            VStack(spacing: 0) {
                FeatureSwitcherItem(
                    icon: "network",
                    title: "REST API",
                    subtitle: "Build and send HTTP requests",
                    isSelected: store.selectedSidebar == .requestBuilder
                ) {
                    store.send(.featureSelected("REST API"))
                }

                Divider()

                FeatureSwitcherItem(
                    icon: "server.rack",
                    title: "Mock Server",
                    subtitle: "Run local mock API server",
                    isSelected: store.selectedSidebar == .mockServer
                ) {
                    store.send(.featureSelected("Mock Server"))
                }
            }
            .frame(width: 280)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
        }
    }
}

// MARK: - Feature Switcher Item
struct FeatureSwitcherItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.primary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }
}
