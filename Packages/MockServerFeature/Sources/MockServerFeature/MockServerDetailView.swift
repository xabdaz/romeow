import ComposableArchitecture
import SharedModels
import SwiftUI

struct MockServerDetailView: View {
    let store: StoreOf<MockServerFeature>

    var body: some View {
        Group {
            if let routeId = store.selectedRouteId,
               let route = store.routes.first(where: { $0.id == routeId }) {
                RouteDetailView(route: route)
            } else {
                ServerControlView(store: store)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: { store.send(.delegate(.featureSwitcherTapped)) }) {
                    HStack(spacing: Spacing.xSmall) {
                        Image(systemName: "server.rack")
                        Text("Mock Server")
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.down")
                            .font(.rmeCaption)
                    }
                }
                .buttonStyle(.plain)
            }

            ToolbarItem(placement: .primaryAction) {
                ServerToolbarButton(store: store)
            }
        }
    }
}

private struct RouteDetailView: View {
    let route: MockRoute

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                HStack {
                    Text(route.method.rawValue)
                        .font(.rmeTitle3Semibold)
                        .foregroundStyle(Color.httpMethod(route.method))
                    Text(route.path)
                        .font(.rmeTitle3)
                        .textSelection(.enabled)
                    Spacer()
                    StatusBadge(isEnabled: route.isEnabled)
                }

                Divider()

                DetailSection(title: "Name") {
                    Text(route.name)
                        .textSelection(.enabled)
                }

                DetailSection(title: "Status Code") {
                    Text("\(route.statusCode)")
                }

                DetailSection(title: "Headers") {
                    if route.responseHeaders.isEmpty {
                        Text("No headers")
                            .foregroundStyle(Color.rmeSecondaryText)
                    } else {
                        Text(formatHeaders(route.responseHeaders))
                            .font(.rmeMonospacedCaption)
                            .textSelection(.enabled)
                    }
                }

                DetailSection(title: "Response Body") {
                    Text(route.responseBody)
                        .font(.rmeMonospaced)
                        .textSelection(.enabled)
                }

                Spacer()
            }
            .padding()
        }
        .frame(minWidth: FrameSize.detailMin)
    }

    private func formatHeaders(_ headers: [String: String]) -> String {
        headers.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            Text(title)
                .font(.rmeCaption)
                .foregroundStyle(Color.rmeSecondaryText)
            content
        }
    }
}

private struct StatusBadge: View {
    let isEnabled: Bool

    var body: some View {
        HStack(spacing: Spacing.xSmall) {
            Circle()
                .fill(isEnabled ? Color.rmeSuccess : Color.rmeSecondaryText)
                .frame(width: 8, height: 8)
            Text(isEnabled ? "Enabled" : "Disabled")
                .font(.rmeCaption)
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.xSmall)
        .background(isEnabled ? Color.rmeSuccess.opacity(0.1) : Color.rmeSecondaryText.opacity(0.1))
        .clipShape(Capsule())
    }
}

private struct ServerToolbarButton: View {
    let store: StoreOf<MockServerFeature>

    var body: some View {
        Button {
            store.send(store.isRunning ? .stopButtonTapped : .startButtonTapped)
        } label: {
            HStack(spacing: Spacing.small) {
                Circle()
                    .fill(store.isRunning ? Color.rmeSuccess : Color.rmeSecondaryText.opacity(0.4))
                    .frame(width: 8, height: 8)

                Text(store.isRunning ? "Stop" : "Start")
                    .fontWeight(.medium)

                Image(systemName: store.isRunning ? "stop.fill" : "play.fill")
                    .font(.rmeCaption)
            }
        }
        .buttonStyle(.bordered)
        .tint(store.isRunning ? Color.rmeError : Color.rmeSuccess)
        .disabled(store.selectedWorkspaceId == nil || store.filteredRoutes.isEmpty)
        .help(store.isRunning ? "Stop mock server" : "Start mock server on port \(store.port)")
        .accessibilityIdentifier("serverToggleButton")
    }
}

private struct ServerControlView: View {
    let store: StoreOf<MockServerFeature>

    var body: some View {
        VStack(spacing: Spacing.xxLarge) {
            serverStatusBadge

            if store.isRunning {
                serverURLInfo
            } else {
                serverStoppedInfo
            }

            if let error = store.errorMessage {
                Text(error)
                    .font(.rmeCaption)
                    .foregroundStyle(Color.rmeError)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if !store.filteredRoutes.isEmpty {
                Divider()
                VStack(spacing: Spacing.xSmall) {
                    Text("\(store.filteredRoutes.filter(\.isEnabled).count) enabled routes")
                        .font(.rmeCaption)
                        .foregroundStyle(Color.rmeSecondaryText)
                    if let workspaceName = store.workspaces.first(where: { $0.id == store.selectedWorkspaceId })?.name {
                        Text("in \"\(workspaceName)\"")
                            .font(.rmeCaption)
                            .foregroundStyle(Color.rmeSecondaryText)
                    }
                }
            } else if store.selectedWorkspaceId != nil {
                ContentUnavailableView("No Routes", systemImage: "doc.text")
                    .frame(maxHeight: 200)
            }

            Spacer()
        }
        .padding(Spacing.huge)
        .frame(minWidth: 360)
    }

    private var serverStatusBadge: some View {
        HStack(spacing: Spacing.small) {
            Circle()
                .fill(store.isRunning ? Color.rmeSuccess : Color.rmeSecondaryText.opacity(0.4))
                .frame(width: 10, height: 10)
                .overlay {
                    if store.isRunning {
                        Circle()
                            .fill(Color.rmeSuccess.opacity(0.3))
                            .frame(width: 18, height: 18)
                    }
                }

            Text(store.isRunning ? "Running" : "Stopped")
                .font(.headline)
                .foregroundStyle(store.isRunning ? .primary : .secondary)
        }
        .accessibilityIdentifier("serverStatusBadge")
    }

    private var serverURLInfo: some View {
        VStack(spacing: Spacing.xSmall) {
            Text("Listening on")
                .font(.rmeCaption)
                .foregroundStyle(Color.rmeSecondaryText)
            Text("http://127.0.0.1:\(store.port)")
                .font(.rmeMonospaced)
                .textSelection(.enabled)
                .accessibilityIdentifier("serverURLLabel")
        }
        .padding(Spacing.medium)
        .background(Color.rmeSurface, in: RoundedRectangle(cornerRadius: CornerRadius.large))
    }

    private var serverStoppedInfo: some View {
        VStack(spacing: Spacing.xSmall) {
            Text("Server is stopped")
                .font(.rmeCaption)
                .foregroundStyle(Color.rmeSecondaryText)
            if store.selectedWorkspaceId == nil {
                Text("Select a workspace to start")
                    .font(.rmeCaption)
                    .foregroundStyle(Color.rmeSecondaryText)
            } else if store.filteredRoutes.isEmpty {
                Text("Add routes to start the server")
                    .font(.rmeCaption)
                    .foregroundStyle(Color.rmeSecondaryText)
            } else {
                Text("Port \(store.port)")
                    .font(.rmeCaption)
                    .foregroundStyle(Color.rmeSecondaryText)
            }
        }
        .padding(Spacing.medium)
        .background(Color.rmeSurface, in: RoundedRectangle(cornerRadius: CornerRadius.large))
    }
}
