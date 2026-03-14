import SwiftUI

struct MockServerSidebarView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Mock Server")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            // Routes List
            List {
                Section("Routes") {
                    HStack {
                        Text("GET")
                            .font(.system(.caption, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
                            .foregroundStyle(.blue)
                        Text("/health")
                            .font(.system(.body, design: .monospaced))
                        Spacer()
                    }
                }
            }
            .listStyle(.sidebar)

            Spacer()
        }
        .frame(minWidth: 200)
    }
}
