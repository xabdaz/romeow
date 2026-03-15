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
                    HStack(spacing: 4) {
                        Image(systemName: "server.rack")
                        Text("Mock Server")
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Route Detail View (Read-only)

private struct RouteDetailView: View {
    let route: MockRoute

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text(route.method.rawValue)
                        .font(.title3.bold())
                        .foregroundStyle(methodColor)
                    Text(route.path)
                        .font(.title3)
                        .textSelection(.enabled)
                    Spacer()
                    StatusBadge(isEnabled: route.isEnabled)
                }

                Divider()

                // Details
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
                            .foregroundStyle(.secondary)
                    } else {
                        Text(formatHeaders(route.responseHeaders))
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }

                DetailSection(title: "Response Body") {
                    Text(route.responseBody)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                }

                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 400)
    }

    private var methodColor: Color {
        switch route.method {
        case .get: return .blue
        case .post: return .green
        case .put: return .orange
        case .delete: return .red
        default: return .gray
        }
    }

    private func formatHeaders(_ headers: [String: String]) -> String {
        headers.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content
        }
    }
}

private struct StatusBadge: View {
    let isEnabled: Bool

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isEnabled ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text(isEnabled ? "Enabled" : "Disabled")
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isEnabled ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Server Control View

private struct ServerControlView: View {
    let store: StoreOf<MockServerFeature>

    var body: some View {
        VStack(spacing: 24) {
            // Status indicator
            serverStatusBadge

            // Server URL info
            if store.isRunning {
                serverURLInfo
            }

            // Start / Stop button
            Button {
                store.send(store.isRunning ? .stopButtonTapped : .startButtonTapped)
            } label: {
                Label(
                    store.isRunning ? "Stop Server" : "Start Server",
                    systemImage: store.isRunning ? "stop.circle.fill" : "play.circle.fill"
                )
                .frame(minWidth: 160)
            }
            .buttonStyle(.borderedProminent)
            .tint(store.isRunning ? .red : .green)
            .controlSize(.large)

            // Error message
            if let error = store.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            // Route count info
            if !store.filteredRoutes.isEmpty {
                Divider()
                VStack(spacing: 4) {
                    Text("\(store.filteredRoutes.filter(\.isEnabled).count) enabled routes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let workspaceName = store.workspaces.first(where: { $0.id == store.selectedWorkspaceId })?.name {
                        Text("in \"\(workspaceName)\"")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if store.selectedWorkspaceId != nil {
                ContentUnavailableView("No Routes", systemImage: "doc.text")
                    .frame(maxHeight: 200)
            }

            Spacer()
        }
        .padding(32)
        .frame(minWidth: 360)
    }

    private var serverStatusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(store.isRunning ? Color.green : Color.secondary.opacity(0.4))
                .frame(width: 10, height: 10)
                .overlay {
                    if store.isRunning {
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 18, height: 18)
                    }
                }

            Text(store.isRunning ? "Running" : "Stopped")
                .font(.headline)
                .foregroundStyle(store.isRunning ? .primary : .secondary)
        }
    }

    private var serverURLInfo: some View {
        VStack(spacing: 4) {
            Text("Listening on")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("http://127.0.0.1:\(store.port)")
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
