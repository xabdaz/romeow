import ComposableArchitecture
import SwiftUI

struct RequestBuilderView: View {
    let store: StoreOf<RequestFeature>

    var body: some View {
        VStack(spacing: 0) {
            // URL Bar
            URLBarView(store: store)

            Divider()

            // Request Body / Headers Section
            RequestConfigView(store: store)

            Divider()

            // Response Section
            ResponseView(store: store)
        }
        .frame(minWidth: 400)
    }
}
