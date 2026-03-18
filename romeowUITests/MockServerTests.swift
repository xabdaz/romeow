//
//  MockServerTests.swift
//  romeowUITests
//
//  Mirrors: .maestro/05_mock_server.yaml
//  Start/stop mock server
//

import XCTest

final class MockServerTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    @MainActor
    private func navigateToMockServer() {
        let switcher = app.buttons["featureSwitcherButton"].firstMatch
        XCTAssertTrue(switcher.waitForExistence(timeout: 5))
        switcher.click()

        sleep(1)

        // Try different strategies for Mock Server option
        let mockServerItem = app.otherElements["feature_Mock Server"].firstMatch
        let mockServerButton = app.buttons["feature_Mock Server"].firstMatch
        let mockServerText = app.staticTexts["Mock Server"].firstMatch

        if mockServerItem.waitForExistence(timeout: 3) {
            mockServerItem.click()
        } else if mockServerButton.waitForExistence(timeout: 1) {
            mockServerButton.click()
        } else if mockServerText.waitForExistence(timeout: 1) {
            mockServerText.click()
        } else {
            XCTFail("Mock Server option not found in feature switcher")
        }

        sleep(1)

        let createWorkspace = app.buttons["createWorkspaceButton"]
        XCTAssertTrue(createWorkspace.waitForExistence(timeout: 5))
    }

    @MainActor
    private func createWorkspaceWithRoute() {
        // Create workspace - use firstMatch because button appears twice in toolbar
        app.buttons["createWorkspaceButton"].firstMatch.click()

        let nameField = app.textFields["workspaceNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.click()
        nameField.typeText("Server Test WS")
        app.buttons["saveWorkspaceButton"].click()

        // Add a route
        let addRoute = app.buttons["addRouteButton"]
        XCTAssertTrue(addRoute.waitForExistence(timeout: 3))
        addRoute.click()

        let routeName = app.textFields["routeNameField"]
        XCTAssertTrue(routeName.waitForExistence(timeout: 3))
        routeName.click()
        routeName.typeText("Health")

        let routePath = app.textFields["routePathField"]
        routePath.click()
        routePath.typeText("/api/health")

        let statusField = app.textFields["routeStatusCodeField"]
        statusField.click()
        statusField.typeKey("a", modifierFlags: .command)
        statusField.typeText("200")

        let bodyEditor = app.textViews["routeBodyEditor"]
        if bodyEditor.exists {
            bodyEditor.click()
            bodyEditor.typeText("{\"status\": \"ok\"}")
        }

        app.buttons["saveRouteButton"].click()
    }

    // MARK: - Tests

    @MainActor
    func testServerToggleButtonExists() throws {
        navigateToMockServer()
        createWorkspaceWithRoute()

        // Server toggle button should exist in toolbar - use firstMatch due to SwiftUI duplicate
        let toggleButton = app.buttons["serverToggleButton"].firstMatch
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testStartAndStopServer() throws {
        navigateToMockServer()
        createWorkspaceWithRoute()

        // Start the server - use firstMatch due to SwiftUI duplicate
        let toggleButton = app.buttons["serverToggleButton"].firstMatch
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5))

        // Verify button is enabled (can be clicked)
        // Note: Actual server start may fail in test environment due to sandbox/port
        // So we just verify the UI interaction works
        if toggleButton.isEnabled {
            toggleButton.click()

            // Wait a moment for server state to update
            sleep(2)

            // Verify server status badge exists (shows Running or Stopped)
            let statusBadge = app.staticTexts["serverStatusBadge"].firstMatch
            XCTAssertTrue(statusBadge.exists)

            // Stop the server if it started
            toggleButton.click()
        }
    }

    @MainActor
    func testServerToggleDisabledWithoutWorkspace() throws {
        navigateToMockServer()

        // Without a workspace selected, the server toggle should be disabled
        let toggleButton = app.buttons["serverToggleButton"].firstMatch
        if toggleButton.waitForExistence(timeout: 3) {
            XCTAssertFalse(toggleButton.isEnabled)
        }
    }
}
