import ComposableArchitecture
import SharedModels
import SwiftUI

public struct RequestSidebarView: View {
    @Bindable var store: StoreOf<RequestSidebarFeature>
    var onFeatureSwitcherTap: (() -> Void)?

    public init(store: StoreOf<RequestSidebarFeature>, onFeatureSwitcherTap: (() -> Void)? = nil) {
        self.store = store
        self.onFeatureSwitcherTap = onFeatureSwitcherTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Horizontal toolbar strip at the top of sidebar
            SidebarToolbarStrip(
                workspace: store.workspaces.first,
                onFeatureSwitcherTap: onFeatureSwitcherTap
            )

            Divider()

            // Main sidebar content with folders and requests
            List(selection: Binding(
                get: { store.selectedItem },
                set: { store.send(.itemSelected($0)) }
            )) {
                // Flatten all workspaces content without section headers
                ForEach(store.workspaces) { workspace in
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
                            isExpanded: store.expandedFolders.contains(folder.id),
                            selectedItem: store.selectedItem,
                            send: { store.send($0) }
                        )
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .frame(minWidth: 220)
    }
}

// MARK: - Sidebar Toolbar Strip
struct SidebarToolbarStrip: View {
    let workspace: Workspace?
    var onFeatureSwitcherTap: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            // Sidebar toggle button (≡)
            Button {
                // Toggle sidebar visibility - handled by NavigationSplitView
            } label: {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            // Feature switcher button (••• / grid)
            Button {
                onFeatureSwitcherTap?()
            } label: {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)

            Spacer()

            // Workspace dropdown title
            if let workspace = workspace {
                Menu {
                    Text("Coming Soon")
                    Button("Switch Workspace") {}
                        .disabled(true)
                } label: {
                    HStack(spacing: 4) {
                        Text(workspace.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(NSColor.controlBackgroundColor))
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
