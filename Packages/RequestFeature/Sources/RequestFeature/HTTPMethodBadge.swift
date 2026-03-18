import SharedModels
import SwiftUI

struct HTTPMethodBadge: View {
    let method: HTTPMethod

    var body: some View {
        Text(method.rawValue)
            .font(.rmeCaptionBold)
            .foregroundStyle(Color.httpMethod(method))
            .frame(width: 32)
            .padding(.vertical, Spacing.xxSmall)
            .background(Color.httpMethod(method).opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}
