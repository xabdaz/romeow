import SwiftUI

public enum SidebarTab: String, CaseIterable {
    case collections
    case environments
    case log

    var icon: String {
        switch self {
        case .collections: "folder"
        case .environments: "slider.horizontal.3"
        case .log: "clock"
        }
    }

    var label: String {
        switch self {
        case .collections: "Collections"
        case .environments: "ENV"
        case .log: "Log"
        }
    }
}
