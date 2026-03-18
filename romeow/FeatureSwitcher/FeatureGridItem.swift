//
//  FeatureGridItem.swift
//  romeow
//

import SwiftUI

struct FeatureGridItem: View {
    let feature: FeatureItem
    var onTap: () -> Void
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: feature.icon)
                .font(.system(size: 22))
                .foregroundStyle(feature.color)
                .frame(width: 44, height: 44)
                .background(
                    feature.color.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 10)
                )

            Text(feature.title)
                .font(.caption)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isHovered ? Color.primary.opacity(0.06) : Color.clear)
        )
        .onHover { isHovered = $0 }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .accessibilityIdentifier("feature_\(feature.title)")
    }
}
