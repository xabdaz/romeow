import SharedModels
import SwiftUI

struct ResponseStatusBar: View {
    let response: APIResponse

    var statusColor: Color {
        Color.httpStatusCode(response.statusCode)
    }

    var body: some View {
        HStack(spacing: Spacing.large) {
            HStack(spacing: Spacing.xSmall) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text("\(response.statusCode)")
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("responseStatusCode")
            }

            Divider()
                .frame(height: 16)

            HStack(spacing: Spacing.xSmall) {
                Image(systemName: "clock")
                    .font(.caption)
                Text(String(format: "%.0f ms", response.duration * 1000))
                    .accessibilityIdentifier("responseDuration")
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.small)
        .background(statusColor.opacity(0.1))
    }
}
