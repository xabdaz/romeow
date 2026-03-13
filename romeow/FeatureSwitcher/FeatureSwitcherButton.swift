//
//  FeatureSwitcherButton.swift
//  romeow
//

import SwiftUI

struct FeatureSwitcherButton: View {
    @State private var isShowingGrid = false

    var body: some View {
        Button {
            isShowingGrid.toggle()
        } label: {
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isShowingGrid ? .blue : .primary)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isShowingGrid ? Color.blue.opacity(0.12) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isShowingGrid, arrowEdge: .bottom) {
            FeatureGridPopup()
        }
    }
}
