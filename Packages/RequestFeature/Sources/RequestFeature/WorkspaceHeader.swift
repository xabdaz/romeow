import SharedModels
import SwiftUI

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
