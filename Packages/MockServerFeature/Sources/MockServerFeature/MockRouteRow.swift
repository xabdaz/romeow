import SharedModels
import SwiftUI

public struct MockRouteRow: View {
    let route: MockRoute

    public init(route: MockRoute) {
        self.route = route
    }

    public var body: some View {
        HStack(spacing: Spacing.small) {
            Text(route.method.rawValue)
                .font(.rmeCaptionBold)
                .foregroundStyle(Color.httpMethod(route.method))
                .frame(width: 50, alignment: .center)

            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(route.name)
                    .font(.rmeBodyMedium)
                Text(route.path)
                    .font(.rmeCaption)
                    .foregroundStyle(Color.rmeSecondaryText)
                    .lineLimit(1)
            }

            Spacer()

            Circle()
                .fill(route.isEnabled ? Color.rmeSuccess : Color.rmeSecondaryText)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, Spacing.xSmall)
    }
}
