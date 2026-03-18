import SharedModels
import SwiftUI

struct SidebarIconButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xxSmall) {
                Image(systemName: icon)
                    .font(.rmeCalloutMedium)
                Text(label)
                    .font(.rmeCaption)
                    .lineLimit(1)
            }
            .foregroundStyle(isActive ? .primary : .secondary)
            .frame(width: 56, height: 44)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(isActive ? Color.rmeActiveBackground : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .help(label)
        .accessibilityIdentifier("sidebar_\(label)")
    }
}
