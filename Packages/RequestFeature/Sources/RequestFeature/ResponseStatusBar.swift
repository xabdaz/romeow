import SharedModels
import SwiftUI

struct ResponseStatusBar: View {
    let response: APIResponse

    var statusColor: Color {
        response.isSuccess ? .green : .red
    }

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text("\(response.statusCode)")
                    .fontWeight(.semibold)
            }

            Divider()
                .frame(height: 16)

            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                Text(String(format: "%.0f ms", response.duration * 1000))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.1))
    }
}
