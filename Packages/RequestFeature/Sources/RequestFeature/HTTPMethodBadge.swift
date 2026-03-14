import SharedModels
import SwiftUI

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
