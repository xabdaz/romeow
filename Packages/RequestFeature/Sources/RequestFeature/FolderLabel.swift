import SharedModels
import SwiftUI

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
