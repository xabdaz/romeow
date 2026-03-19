import ComposableArchitecture
import SharedModels
import SwiftUI

struct RequestBodyView: View {
    let store: StoreOf<RequestFeature>

    var body: some View {
        VStack(spacing: 0) {
            // Body Type Picker
            HStack {
                BodyTypePicker(store: store)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Content based on body type
            bodyContentView
        }
    }

    @ViewBuilder
    private var bodyContentView: some View {
        switch store.request.bodyType {
        case .none:
            EmptyBodyView()
        case .json:
            JSONBodyView(store: store)
        case .formUrlEncoded:
            FormUrlEncodedBodyView(store: store)
        case .raw:
            RawBodyView(store: store)
        }
    }
}

struct EmptyBodyView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No body content")
                .foregroundStyle(.secondary)
            Text("Select a body type above to add content")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct JSONBodyView: View {
    let store: StoreOf<RequestFeature>

    private var jsonContent: String {
        if case .json(let content) = store.request.bodyContent {
            return content
        }
        return ""
    }

    var body: some View {
        VStack(spacing: 0) {
            // JSON Header info
            HStack {
                Text("Content-Type: application/json")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            Divider()

            // Text Editor
            TextEditor(text: Binding(
                get: { jsonContent },
                set: { store.send(.bodyContentChanged(.json($0))) }
            ))
            .font(.system(.body, design: .monospaced))
            .padding(4)
            .accessibilityIdentifier("jsonBodyEditor")
        }
    }
}
