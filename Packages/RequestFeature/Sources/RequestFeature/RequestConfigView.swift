import ComposableArchitecture
import SwiftUI

struct RequestConfigView: View {
    let store: StoreOf<RequestFeature>
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Body").tag(0)
                Text("Headers").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                RequestBodyView(store: store)
            } else {
                RequestHeadersView(store: store)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
