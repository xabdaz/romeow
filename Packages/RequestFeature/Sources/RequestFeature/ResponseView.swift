import ComposableArchitecture
import SwiftUI

struct ResponseView: View {
    let store: StoreOf<RequestFeature>
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Response Status Bar
            if let response = store.response {
                ResponseStatusBar(response: response)
            } else if let errorMessage = store.errorMessage {
                ErrorStatusBar(message: errorMessage)
            } else {
                EmptyResponseBar()
            }

            // Response Content
            if store.response != nil {
                Picker("", selection: $selectedTab) {
                    Text("Body").tag(0)
                    Text("Headers").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    ResponseBodyView(response: store.response)
                } else {
                    ResponseHeadersView(response: store.response)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}
