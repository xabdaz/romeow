//
//  romeowApp.swift
//  romeow
//
//  Created by xabdaz on 13/03/26.
//

import SwiftUI
import ComposableArchitecture
import AppFeature
import MockServerFeature

@main
struct romeowApp: App {
    @State var store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        Window("romeow", id: "main") {
            ContentView(store: store)
        }

        MenuBarExtra {
            MenuBarView(store: store)
        } label: {
            Image(systemName: store.mockServer.isRunning ? "network.badge.shield.half.filled" : "network")
        }
    }
}
