import SwiftUI

struct EmptyResponseBar: View {
    var body: some View {
        HStack {
            Text("No response yet")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.05))
        .accessibilityIdentifier("emptyResponseBar")
    }
}
