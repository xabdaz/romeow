import SharedModels
import SwiftUI

struct ResponseBodyView: View {
    let response: APIResponse?

    var body: some View {
        ScrollView {
            Text(response?.bodyString ?? "")
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .accessibilityIdentifier("responseBodyText")
        }
        .background(Color(NSColor.textBackgroundColor))
    }
}
