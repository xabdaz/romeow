//
//  SubFeatureSwitcherButton.swift
//  romeow
//

import SwiftUI

struct SubFeatureSwitcherButton: View {
    let title: String
    let items: [String]
    var onSelect: ((String) -> Void)?

    var body: some View {
        Menu {
            ForEach(items, id: \.self) { item in
                Button(item) {
                    onSelect?(item)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}
