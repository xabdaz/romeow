import ComposableArchitecture
import SharedModels
import SwiftUI

struct RawBodyView: View {
    let store: StoreOf<RequestFeature>

    private var content: String {
        if case .raw(let content, _) = store.request.bodyContent {
            return content
        }
        return ""
    }

    private var contentType: String {
        if case .raw(_, let ct) = store.request.bodyContent {
            return ct
        }
        return "text/plain"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Content Type Picker
            HStack {
                Text("Content-Type:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("", selection: Binding(
                    get: { contentType },
                    set: { newType in
                        store.send(.bodyContentChanged(.raw(content, contentType: newType)))
                    }
                )) {
                    Text("text/plain").tag("text/plain")
                    Text("text/html").tag("text/html")
                    Text("text/xml").tag("text/xml")
                    Text("application/xml").tag("application/xml")
                    Text("application/javascript").tag("application/javascript")
                    Text("text/css").tag("text/css")
                }
                .pickerStyle(.menu)
                .labelsHidden()
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Text Editor
            TextEditor(text: Binding(
                get: { content },
                set: { store.send(.bodyContentChanged(.raw($0, contentType: contentType))) }
            ))
            .font(.system(.body, design: .monospaced))
            .padding(4)
            .accessibilityIdentifier("rawBodyEditor")
        }
    }
}
