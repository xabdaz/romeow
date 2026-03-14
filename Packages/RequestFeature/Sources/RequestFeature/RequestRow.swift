import SharedModels
import SwiftUI

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
