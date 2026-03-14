import SharedModels
import SwiftUI

struct ResponseHeadersView: View {
    let response: APIResponse?

    var body: some View {
        List {
            ForEach(Array((response?.headers ?? [:]).sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                HStack {
                    Text(key)
                        .font(.system(.body, design: .monospaced))
                    Spacer()
                    Text(value)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
