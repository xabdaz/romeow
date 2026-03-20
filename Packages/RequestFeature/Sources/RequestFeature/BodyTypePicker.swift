import ComposableArchitecture
import SharedModels
import SwiftUI

struct BodyTypePicker: View {
    let store: StoreOf<RequestFeature>

    var body: some View {
        Picker("Body Type", selection: Binding(
            get: { store.request.bodyType },
            set: { store.send(.bodyTypeChanged($0)) }
        )) {
            ForEach(BodyType.allCases, id: \.self) { type in
                Text(type.displayName)
                    .tag(type)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 300)
        .accessibilityIdentifier("bodyTypePicker")
    }
}
