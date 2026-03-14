import ComposableArchitecture
import SharedModels
import SwiftUI

// MARK: - Sidebar Tab
enum SidebarTab: String, CaseIterable {
    case collections
    case environments
    case log

    var icon: String {
        switch self {
        case .collections: "folder"
        case .environments: "slider.horizontal.3"
        case .log: "clock"
        }
    }

    var label: String {
        switch self {
        case .collections: "Collections"
        case .environments: "Environments"
        case .log: "Log"
        }
    }
}

public struct RequestSidebarView: View {
    @Bindable var store: StoreOf<RequestSidebarFeature>
    @State private var activeTab: SidebarTab? = .collections

    public init(store: StoreOf<RequestSidebarFeature>) {
        self.store = store
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Vertical icon strip
            SidebarIconStrip(activeTab: $activeTab)

            Divider()

            // Content panel (show/hide based on activeTab)
            if let tab = activeTab {
                sidebarContent(for: tab)
                    .frame(minWidth: 200)
            }
        }
        .frame(minWidth: activeTab != nil ? 280 : 64)
    }

    @ViewBuilder
    private func sidebarContent(for tab: SidebarTab) -> some View {
        switch tab {
        case .collections:
            List(selection: Binding(
                get: { store.selectedItem },
                set: { store.send(.itemSelected($0)) }
            )) {
                ForEach(store.workspaces) { workspace in
                    ForEach(workspace.requests) { request in
                        RequestRow(request: request)
                            .tag(SidebarItem.request(request.id))
                            .contextMenu {
                                Button("Delete") { }
                            }
                    }

                    ForEach(workspace.folders) { folder in
                        FolderDisclosureGroup(
                            folder: folder,
                            isExpanded: store.expandedFolders.contains(folder.id),
                            selectedItem: store.selectedItem,
                            send: { store.send($0) }
                        )
                    }
                }
            }
            .listStyle(.sidebar)

        case .environments:
            List {
                Text("No environments yet")
                    .foregroundStyle(.secondary)
            }
            .listStyle(.sidebar)

        case .log:
            List {
                Text("No logs yet")
                    .foregroundStyle(.secondary)
            }
            .listStyle(.sidebar)
        }
    }
}

// MARK: - Sidebar Icon Strip
struct SidebarIconStrip: View {
    @Binding var activeTab: SidebarTab?

    var body: some View {
        VStack(spacing: 4) {
            ForEach(SidebarTab.allCases, id: \.self) { tab in
                SidebarIconButton(
                    icon: tab.icon,
                    label: tab.label,
                    isActive: activeTab == tab
                ) {
                    // Toggle: tap active tab to hide panel
                    if activeTab == tab {
                        activeTab = nil
                    } else {
                        activeTab = tab
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .frame(width: 64)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Sidebar Icon Button
struct SidebarIconButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(isActive ? .primary : .secondary)
            .frame(width: 56, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isActive ? Color.accentColor.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .help(label)
    }
}

// MARK: - Workspace Section
struct WorkspaceSection: View {
    let workspace: Workspace
    let expandedFolders: Set<UUID>
    let selectedItem: SidebarItem?
    let send: (RequestSidebarFeature.Action) -> Void

    var body: some View {
        // Root requests (requests yang langsung di workspace, bukan di folder)
        ForEach(workspace.requests) { request in
            RequestRow(request: request)
                .tag(SidebarItem.request(request.id))
                .contextMenu {
                    Button("Delete") { }
                }
        }

        // Folders
        ForEach(workspace.folders) { folder in
            FolderDisclosureGroup(
                folder: folder,
                isExpanded: expandedFolders.contains(folder.id),
                selectedItem: selectedItem,
                send: send
            )
        }
    }
}

// MARK: - Workspace Header
struct WorkspaceHeader: View {
    let workspace: Workspace

    var body: some View {
        HStack {
            Image(systemName: "briefcase")
                .foregroundStyle(.secondary)
            Text(workspace.name)
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Folder Disclosure Group
struct FolderDisclosureGroup: View {
    let folder: Folder
    let isExpanded: Bool
    let selectedItem: SidebarItem?
    let send: (RequestSidebarFeature.Action) -> Void

    var body: some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { isExpanded },
                set: { _ in send(.folderToggled(folder.id)) }
            )
        ) {
            ForEach(folder.requests) { request in
                RequestRow(request: request)
                    .tag(SidebarItem.request(request.id))
                    .padding(.leading, 16)
                    .contextMenu {
                        Button("Delete") { }
                    }
            }
        } label: {
            FolderLabel(folder: folder)
                .tag(SidebarItem.folder(folder.id))
                .contentShape(Rectangle())
                .onTapGesture {
                    send(.itemSelected(.folder(folder.id)))
                }
        }
    }
}

// MARK: - Folder Label
struct FolderLabel: View {
    let folder: Folder

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "folder")
                .foregroundStyle(.yellow)
            Text(folder.name)
                .lineLimit(1)
            Spacer()
            Text("\(folder.requests.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Request Row
struct RequestRow: View {
    let request: RequestItem

    var body: some View {
        HStack(spacing: 6) {
            HTTPMethodBadge(method: request.method)
            Text(request.name)
                .lineLimit(1)
            Spacer()
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }
}

// MARK: - HTTP Method Badge
struct HTTPMethodBadge: View {
    let method: HTTPMethod

    var color: Color {
        switch method {
        case .get: .blue
        case .post: .green
        case .put: .orange
        case .patch: .purple
        case .delete: .red
        case .head, .options: .gray
        }
    }

    var body: some View {
        Text(method.rawValue)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(color)
            .frame(width: 32)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
