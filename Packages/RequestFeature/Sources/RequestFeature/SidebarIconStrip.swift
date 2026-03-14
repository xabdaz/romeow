import SwiftUI

struct SidebarIconStrip: View {
    @Binding var activeTab: SidebarTab

    var body: some View {
        VStack(spacing: 4) {
            ForEach(SidebarTab.allCases, id: \.self) { tab in
                SidebarIconButton(
                    icon: tab.icon,
                    label: tab.label,
                    isActive: activeTab == tab
                ) {
                    activeTab = tab
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .frame(width: 64)
        .background(Color(NSColor.controlBackgroundColor))
    }
}
