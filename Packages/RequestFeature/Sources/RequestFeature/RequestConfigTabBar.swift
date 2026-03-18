import SharedModels
import SwiftUI

enum RequestConfigTab: String, CaseIterable {
    case headers = "Headers"
    case body = "Body"
    case scripts = "Scripts"
}

struct RequestConfigTabBar: View {
    @Binding var selectedTab: RequestConfigTab
    let headerCount: Int

    var body: some View {
        HStack(spacing: Spacing.xxLarge) {
            ForEach(RequestConfigTab.allCases, id: \.self) { tab in
                RequestConfigTabItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    badgeCount: tab == .headers ? headerCount : nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.large)
        .padding(.vertical, Spacing.small)
        .background(Color.rmeWindowBackground)
    }
}

struct RequestConfigTabItem: View {
    let tab: RequestConfigTab
    let isSelected: Bool
    let badgeCount: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.small) {
                HStack(spacing: Spacing.xSmall) {
                    Text(tab.rawValue)
                        .font(isSelected ? .rmeBodyMedium : .rmeBody)
                        .foregroundColor(isSelected ? .primary : .secondary)

                    if let count = badgeCount, count > 0 {
                        Text("(\(count))")
                            .font(.rmeBody)
                            .foregroundColor(.rmeSuccess)
                    }
                }

                Rectangle()
                    .fill(isSelected ? Color.rmeSuccess : Color.clear)
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("tab_\(tab.rawValue)")
    }
}

#Preview {
    @Previewable @State var selectedTab: RequestConfigTab = .body

    VStack {
        RequestConfigTabBar(selectedTab: $selectedTab, headerCount: 9)
        Spacer()
    }
    .frame(width: 400, height: 300)
    .background(Color.rmeWindowBackground)
}
