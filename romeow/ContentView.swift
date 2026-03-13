//
//  ContentView.swift
//  romeow
//
//  Created by xabdaz on 13/03/26.
//

import SwiftUI
import ComposableArchitecture
import AppFeature
import MockServerFeature

struct ContentView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        MockServerView(store: store.scope(state: \.mockServer, action: \.mockServer))
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    FeatureSwitcherButton()
                }
            }
    }
}

#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
