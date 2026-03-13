//
//  MenuBarView.swift
//  romeow
//
//  Created by xabdaz on 13/03/26.
//

import SwiftUI
import ComposableArchitecture
import AppFeature
import MockServerFeature

struct MenuBarView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Status
            HStack(spacing: 6) {
                Circle()
                    .fill(store.mockServer.isRunning ? Color.green : Color.secondary.opacity(0.4))
                    .frame(width: 8, height: 8)
                Text(store.mockServer.isRunning
                     ? "http://127.0.0.1:\(store.mockServer.port)"
                     : "Server stopped")
                    .font(.system(.caption, design: .monospaced))
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            Divider()

            // Start / Stop
            Button {
                store.send(store.mockServer.isRunning
                           ? .mockServer(.stopButtonTapped)
                           : .mockServer(.startButtonTapped))
            } label: {
                Label(
                    store.mockServer.isRunning ? "Stop Server" : "Start Server",
                    systemImage: store.mockServer.isRunning ? "stop.circle" : "play.circle"
                )
            }
            .padding(.horizontal, 4)

            Divider()

            Button("Quit romeow") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .frame(minWidth: 220)
    }
}
