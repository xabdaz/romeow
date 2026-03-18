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
        HStack(spacing: 24) {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct RequestConfigTabItem: View {
    let tab: RequestConfigTab
    let isSelected: Bool
    let badgeCount: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text(tab.rawValue)
                        .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                        .foregroundColor(isSelected ? .primary : .secondary)

                    if let count = badgeCount, count > 0 {
                        Text("(\(count))")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.green)
                    }
                }

                // Underline indicator
                Rectangle()
                    .fill(isSelected ? Color.green : Color.clear)
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
    .background(Color(nsColor: .windowBackgroundColor))
}
