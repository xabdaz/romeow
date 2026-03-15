import SharedModels
import SwiftUI

public struct MockRouteRow: View {
    let route: MockRoute

    public init(route: MockRoute) {
        self.route = route
    }

    public var body: some View {
        HStack(spacing: 8) {
            // Method badge
            Text(route.method.rawValue)
                .font(.caption.bold())
                .foregroundStyle(methodColor)
                .frame(width: 50, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(route.name)
                    .font(.system(size: 13, weight: .medium))
                Text(route.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Status indicator
            Circle()
                .fill(route.isEnabled ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
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
}
