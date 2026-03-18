import ComposableArchitecture
import SharedModels
import SwiftUI

public struct RouteEditorSheet: View {
    @Bindable var store: StoreOf<MockServerFeature>
    @Environment(\.dismiss) private var dismiss
    @State private var bodyJsonError: String?
    @State private var headersJsonError: String?

    private var isSaveDisabled: Bool {
        validateJSON(store.routeFormState.responseBody) != nil ||
        validateJSON(store.routeFormState.responseHeaders) != nil
    }

    public init(store: StoreOf<MockServerFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: .init(
                        get: { store.routeFormState.name },
                        set: { store.send(.routeFormFieldChanged(.name($0))) }
                    ))
                    .accessibilityIdentifier("routeNameField")

                    TextField("Path (e.g., /api/users)", text: .init(
                        get: { store.routeFormState.path },
                        set: { store.send(.routeFormFieldChanged(.path($0))) }
                    ))
                    .accessibilityIdentifier("routePathField")

                    Picker("Method", selection: .init(
                        get: { store.routeFormState.method },
                        set: { store.send(.routeFormFieldChanged(.method($0))) }
                    )) {
                        ForEach(HTTPMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .accessibilityIdentifier("routeMethodPicker")
                }

                Section("Response") {
                    TextField("Status Code", text: .init(
                        get: { store.routeFormState.statusCode },
                        set: { store.send(.routeFormFieldChanged(.statusCode($0))) }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("routeStatusCodeField")

                    // Headers JSON Editor
                    VStack(alignment: .leading, spacing: Spacing.xSmall) {
                        HStack {
                            Text("Headers (JSON)")
                                .font(.rmeCaption)
                                .foregroundStyle(Color.rmeSecondaryText)

                            Spacer()

                            Button("Format") {
                                formatHeaders()
                            }
                            .buttonStyle(.borderless)
                            .font(.rmeCaption)
                            .accessibilityIdentifier("formatHeadersButton")
                        }

                        JSONTextEditor(
                            text: .init(
                                get: { store.routeFormState.responseHeaders },
                                set: { newValue in
                                    let corrected = correctJSONQuotes(newValue)
                                    store.send(.routeFormFieldChanged(.responseHeaders(corrected)))
                                }
                            ),
                            error: headersJsonError
                        )
                        .frame(height: 80)
                        .accessibilityIdentifier("routeHeadersEditor")
                    }

                    // Response Body JSON Editor
                    VStack(alignment: .leading, spacing: Spacing.xSmall) {
                        HStack {
                            Text("Response Body")
                                .font(.rmeCaption)
                                .foregroundStyle(Color.rmeSecondaryText)

                            Spacer()

                            if let error = bodyJsonError {
                                Label(error, systemImage: "exclamationmark.triangle")
                                    .font(.rmeCaption)
                                    .foregroundStyle(Color.rmeError)
                            }

                            Button("Format") {
                                formatBody()
                            }
                            .buttonStyle(.borderless)
                            .font(.rmeCaption)
                            .disabled(bodyJsonError != nil)
                            .accessibilityIdentifier("formatBodyButton")
                        }

                        JSONTextEditor(
                            text: .init(
                                get: { store.routeFormState.responseBody },
                                set: { newValue in
                                    let corrected = correctJSONQuotes(newValue)
                                    store.send(.routeFormFieldChanged(.responseBody(corrected)))
                                }
                            ),
                            error: bodyJsonError
                        )
                        .frame(minHeight: 200)
                        .accessibilityIdentifier("routeBodyEditor")
                    }
                }

                Section {
                    Toggle("Enabled", isOn: .init(
                        get: { store.routeFormState.isEnabled },
                        set: { store.send(.routeFormFieldChanged(.isEnabled($0))) }
                    ))
                    .accessibilityIdentifier("routeEnabledToggle")
                }
            }
            .formStyle(.grouped)
            .navigationTitle(store.routeFormState.id == nil ? "New Route" : "Edit Route")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.routeEditorSheetDismissed)
                    }
                    .accessibilityIdentifier("cancelRouteButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Validate before save
                        let bodyValid = validateJSON(store.routeFormState.responseBody) == nil
                        let headersValid = validateJSON(store.routeFormState.responseHeaders) == nil
                        if bodyValid && headersValid {
                            store.send(.saveRouteTapped)
                        }
                    }
                    .disabled(isSaveDisabled)
                    .accessibilityIdentifier("saveRouteButton")
                }
            }
        }
        .frame(minWidth: 600, minHeight: 700)
    }

    private func validateBody(_ text: String) {
        guard !text.isEmpty else {
            bodyJsonError = nil
            return
        }
        if let error = validateJSON(text) {
            bodyJsonError = error
        } else {
            bodyJsonError = nil
        }
    }

    private func validateHeaders(_ text: String) {
        guard !text.isEmpty else {
            headersJsonError = nil
            return
        }
        if let error = validateJSON(text) {
            headersJsonError = error
        } else {
            headersJsonError = nil
        }
    }

    private func validateJSON(_ text: String) -> String? {
        guard let data = text.data(using: .utf8) else {
            return "Invalid UTF-8"
        }
        do {
            _ = try JSONSerialization.jsonObject(with: data)
            return nil
        } catch {
            return "Invalid JSON"
        }
    }

    private func formatBody() {
        let text = store.routeFormState.responseBody
        guard !text.isEmpty else {
            bodyJsonError = nil
            return
        }
        if let formatted = formatJSON(text) {
            store.send(.routeFormFieldChanged(.responseBody(formatted)))
            bodyJsonError = nil
        } else {
            bodyJsonError = "Invalid JSON"
        }
    }

    private func formatHeaders() {
        let text = store.routeFormState.responseHeaders
        guard !text.isEmpty else {
            headersJsonError = nil
            return
        }
        if let formatted = formatJSON(text) {
            store.send(.routeFormFieldChanged(.responseHeaders(formatted)))
            headersJsonError = nil
        } else {
            headersJsonError = "Invalid JSON"
        }
    }

    private func formatJSON(_ text: String) -> String? {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(
                withJSONObject: json,
                options: [.prettyPrinted, .sortedKeys]
              ) else {
            return nil
        }
        return String(data: prettyData, encoding: .utf8)
    }

    /// Replace smart/curly quotes with straight quotes for valid JSON
    private func correctJSONQuotes(_ text: String) -> String {
        // Smart quotes (curly) yang sering ke-copy dari Word/docs di-convert ke straight quotes
        return text
            .replacingOccurrences(of: "\u{201C}", with: "\"")  // Left double quote
            .replacingOccurrences(of: "\u{201D}", with: "\"")  // Right double quote
            .replacingOccurrences(of: "\u{2018}", with: "'")   // Left single quote
            .replacingOccurrences(of: "\u{2019}", with: "'")   // Right single quote
    }
}

// MARK: - JSON Text Editor Component

struct JSONTextEditor: View {
    @Binding var text: String
    var error: String?

    var body: some View {
        TextEditor(text: $text)
            .font(.rmeMonospaced)
            .scrollContentBackground(.hidden)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.rmeTextBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(error != nil ? Color.rmeError : Color.rmeBorder, lineWidth: BorderWidth.thin)
            )
    }
}
