import SharedModels
import SwiftUI

struct ErrorStatusBar: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.rmeError)
            Text(message)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.small)
        .background(Color.rmeError.opacity(0.1))
        .accessibilityIdentifier("errorStatusBar")
    }
}
