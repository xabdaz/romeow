import SharedModels
import SwiftUI

struct EmptyResponseBar: View {
    var body: some View {
        HStack {
            Text("No response yet")
                .foregroundStyle(Color.rmeSecondaryText)
            Spacer()
        }
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.small)
        .background(Color.rmeQuaternaryText.opacity(0.1))
        .accessibilityIdentifier("emptyResponseBar")
    }
}
