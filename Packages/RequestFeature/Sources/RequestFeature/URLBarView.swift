import ComposableArchitecture
import SharedModels
import SwiftUI

struct URLBarView: View {
    let store: StoreOf<RequestFeature>

    var body: some View {
        HStack(spacing: 12) {
            // Method Picker
            Picker("", selection: Binding(
                get: { store.request.method },
                set: { store.send(.methodChanged($0)) }
            )) {
                ForEach(HTTPMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)

            // URL TextField
            TextField("Enter URL", text: Binding(
                get: { store.request.url },
                set: { store.send(.urlChanged($0)) }
            ))
            .textFieldStyle(.roundedBorder)

            // Send Button
            Button(action: { store.send(.sendButtonTapped) }) {
                HStack(spacing: 4) {
                    if store.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text("Send")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .disabled(store.isLoading || store.request.url.isEmpty)
        }
        .padding()
    }
}
