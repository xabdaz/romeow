import ComposableArchitecture
import SwiftUI

struct RequestBodyView: View {
    let store: StoreOf<RequestFeature>

    var body: some View {
        TextEditor(text: Binding(
            get: { store.request.body ?? "" },
            set: { store.send(.bodyChanged($0)) }
        ))
        .font(.system(.body, design: .monospaced))
        .padding(4)
        .accessibilityIdentifier("requestBodyEditor")
    }
}
