//
//  ContentView.swift
//  romeow
//
//  Created by xabdaz on 13/03/26.
//

import SwiftUI
import ComposableArchitecture
import AppFeature

struct ContentView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        AppView(store: store)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    FeatureSwitcherButton { featureTitle in
                        switch featureTitle {
                        case "REST API":
                            store.send(.sidebarItemSelected(.requestBuilder))
                        case "Mock Server":
                            store.send(.sidebarItemSelected(.mockServer))
                        default:
                            break
                        }
                    }
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
