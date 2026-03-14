//
//  FeatureGridPopup.swift
//  romeow
//

import SwiftUI

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

#Preview {
    FeatureGridPopup()
        .frame(width: 200)
}
