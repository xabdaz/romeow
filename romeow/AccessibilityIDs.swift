//
//  AccessibilityIDs.swift
//  romeow
//
//  Shared accessibility identifier constants used by both the app and UI tests.
//  Single source of truth for all identifiers.
//

import Foundation

public enum AccessibilityIDs {
    // MARK: - Request Feature

    static let httpMethodPicker = "httpMethodPicker"
    static let urlTextField = "urlTextField"
    static let sendButton = "sendButton"

    // Request Config
    static let requestConfigPicker = "requestConfigPicker"
    static let requestBodyEditor = "requestBodyEditor"

    // Request Headers
    static let headerKeyField = "headerKeyField"
    static let headerValueField = "headerValueField"
    static let addHeaderButton = "addHeaderButton"

    // Response
    static let responseTabPicker = "responseTabPicker"
    static let responseStatusCode = "responseStatusCode"
    static let responseDuration = "responseDuration"
    static let responseBodyText = "responseBodyText"
    static let emptyResponseBar = "emptyResponseBar"
    static let errorStatusBar = "errorStatusBar"

    // MARK: - Mock Server Feature

    // Workspace Picker
    static let workspacePicker = "workspacePicker"
    static let addRouteButton = "addRouteButton"
    static let deleteWorkspaceButton = "deleteWorkspaceButton"

    // Sidebar
    static let createWorkspaceButton = "createWorkspaceButton"
    static let routesList = "routesList"

    // Server Control
    static let serverToggleButton = "serverToggleButton"
    static let serverStatusBadge = "serverStatusBadge"
    static let serverURLLabel = "serverURLLabel"

    // Create Workspace Sheet
    static let workspaceNameField = "workspaceNameField"
    static let cancelWorkspaceButton = "cancelWorkspaceButton"
    static let saveWorkspaceButton = "saveWorkspaceButton"

    // Route Editor Sheet
    static let routeNameField = "routeNameField"
    static let routePathField = "routePathField"
    static let routeMethodPicker = "routeMethodPicker"
    static let routeStatusCodeField = "routeStatusCodeField"
    static let routeHeadersEditor = "routeHeadersEditor"
    static let routeBodyEditor = "routeBodyEditor"
    static let formatHeadersButton = "formatHeadersButton"
    static let formatBodyButton = "formatBodyButton"
    static let routeEnabledToggle = "routeEnabledToggle"
    static let cancelRouteButton = "cancelRouteButton"
    static let saveRouteButton = "saveRouteButton"

    // MARK: - App-level

    static let featureSwitcherButton = "featureSwitcherButton"

    /// Dynamic identifier for feature grid items: "feature_{title}"
    static func featureGridItem(_ title: String) -> String {
        "feature_\(title)"
    }

    /// Dynamic identifier for sidebar buttons: "sidebar_{label}"
    static func sidebarButton(_ label: String) -> String {
        "sidebar_\(label)"
    }
}
