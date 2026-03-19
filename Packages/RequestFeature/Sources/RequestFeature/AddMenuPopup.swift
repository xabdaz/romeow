import SwiftUI

public struct AddMenuPopup: View {
    public var onAddRequest: () -> Void
    public var onAddFolder: () -> Void

    public init(onAddRequest: @escaping () -> Void, onAddFolder: @escaping () -> Void) {
        self.onAddRequest = onAddRequest
        self.onAddFolder = onAddFolder
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                onAddRequest()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 24, height: 24)

                    Text("New Request")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.horizontal, 8)

            Button {
                onAddFolder()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 24, height: 24)

                    Text("New Folder")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 160)
        .padding(.vertical, 4)
    }
}

#Preview {
    AddMenuPopup(onAddRequest: {}, onAddFolder: {})
}
