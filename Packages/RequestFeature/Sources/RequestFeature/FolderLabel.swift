import SharedModels
import SwiftUI

struct FolderLabel: View {
    let folder: Folder

    var body: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "folder")
                .foregroundStyle(.yellow)
            Text(folder.name)
                .lineLimit(1)
            Spacer()
            Text("\(folder.requests.count)")
                .font(.rmeCaption)
                .foregroundStyle(Color.rmeSecondaryText)
                .padding(.horizontal, Spacing.small)
                .padding(.vertical, Spacing.xxSmall)
                .background(Color.rmeQuaternaryText.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(.vertical, Spacing.xxSmall)
    }
}
