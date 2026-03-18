import ComposableArchitecture
import SharedModels
import SwiftUI

public struct FeatureSwitcherItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onSelect: () -> Void

    public init(
        icon: String,
        title: String,
        subtitle: String,
        isSelected: Bool,
        onSelect: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.medium) {
                Image(systemName: icon)
                    .font(.rmeTitle2)
                    .foregroundStyle(.primary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    Text(title)
                        .font(.rmeCalloutSemibold)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.rmeFootnote)
                        .foregroundStyle(Color.rmeSecondaryText)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.rmeCaptionBold)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.medium)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.rmeSelectionBackground : Color.clear)
    }
}
