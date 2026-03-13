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
            .overlay {
                if store.isFeatureSwitcherVisible {
                    FeatureSwitcherOverlay(store: store)
                }
            }
    }
}

struct FeatureSwitcherOverlay: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        ZStack {
            // Semi-transparent background to dismiss on tap outside
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    store.send(.featureSwitcherTapped)
                }

            // Feature switcher popup positioned near the sidebar toggle area
            VStack {
                HStack {
                    FeatureGridPopup { feature in
                        store.send(.featureSelected(feature.title))
                    }
                    .padding(.leading, 60)
                    .padding(.top, 40)

                    Spacer()
                }

                Spacer()
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
