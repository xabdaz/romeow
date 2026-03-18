import SharedModels
import SwiftUI

struct SidebarIconStrip: View {
    @Binding var activeTab: SidebarTab

    var body: some View {
        VStack(spacing: Spacing.xSmall) {
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
        .padding(.vertical, Spacing.small)
        .frame(width: FrameSize.sidebarMin)
        .background(Color.rmeSurface)
    }
}
