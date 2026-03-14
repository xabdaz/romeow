//
//  FeatureGridPopup.swift
//  romeow
//

import SwiftUI

struct FeatureItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

private let features: [FeatureItem] = [
    FeatureItem(title: "REST API",     icon: "network",              color: .blue),
    FeatureItem(title: "Mock Server",  icon: "server.rack",          color: .green),
    FeatureItem(title: "Settings",     icon: "gearshape.fill",       color: .gray),
]

struct FeatureGridPopup: View {
    private let columns = [
        GridItem(.fixed(80)),
        GridItem(.fixed(80)),
    ]

    var onSelect: ((FeatureItem) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("romeow")
                .font(.headline)
                .foregroundStyle(.primary)

            Divider()

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(features) { feature in
                    FeatureGridItem(feature: feature) {
                        onSelect?(feature)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 200)
    }
}

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
    }
}

#Preview {
    FeatureGridPopup()
        .frame(width: 200)
}
