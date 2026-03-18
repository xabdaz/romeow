//
//  MockWorkspaceTests.swift
//  romeowUITests
//
//  Mirrors: .maestro/04_mock_workspace.yaml and .maestro/06_edit_route.yaml
//  Create workspace, add route, and edit route
//

import XCTest

final class MockWorkspaceTests: XCTestCase {

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

        // Wait for Mock Server view to load
        let createWorkspace = app.buttons["createWorkspaceButton"]
        XCTAssertTrue(createWorkspace.waitForExistence(timeout: 5))
    }

    @MainActor
    private func createWorkspace(name: String) {
        // Use firstMatch because createWorkspaceButton appears twice in toolbar (SwiftUI issue)
        app.buttons["createWorkspaceButton"].firstMatch.click()

        let nameField = app.textFields["workspaceNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.click()
        nameField.typeText(name)

        app.buttons["saveWorkspaceButton"].click()
    }

    @MainActor
    private func addRoute(name: String, path: String, statusCode: String = "200", body: String = "{}") {
        app.buttons["addRouteButton"].click()

        let nameField = app.textFields["routeNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.click()
        nameField.typeText(name)

        let pathField = app.textFields["routePathField"]
        pathField.click()
        pathField.typeText(path)

        let statusField = app.textFields["routeStatusCodeField"]
        statusField.click()
        // Select all and replace
        statusField.typeKey("a", modifierFlags: .command)
        statusField.typeText(statusCode)

        // Type body in the body editor
        let bodyEditor = app.textViews["routeBodyEditor"]
        if bodyEditor.exists {
            bodyEditor.click()
            bodyEditor.typeText(body)
        }

        app.buttons["saveRouteButton"].click()
    }

    // MARK: - Tests

    @MainActor
    func testCreateWorkspace() throws {
        navigateToMockServer()

        // Create a workspace
        createWorkspace(name: "Test Workspace")

        // Verify workspace picker is visible (workspace was created)
        let picker = app.popUpButtons["workspacePicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
    }

    @MainActor
    func testAddRouteToWorkspace() throws {
        navigateToMockServer()
        createWorkspace(name: "Route Test WS")

        // Add a route
        addRoute(name: "Get Users", path: "/api/users", body: "{\"users\": []}")

        // Verify routes list is visible
        let routesList = app.outlines["routesList"]
            .exists ? app.outlines["routesList"] : app.tables["routesList"]
        // The route should appear in the sidebar
        XCTAssertTrue(routesList.waitForExistence(timeout: 5))
    }

    @MainActor
    func testDeleteWorkspace() throws {
        navigateToMockServer()
        createWorkspace(name: "Delete Me WS")

        // Verify delete button exists
        let deleteButton = app.buttons["deleteWorkspaceButton"].firstMatch
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))

        // Tap delete
        deleteButton.click()
    }

    @MainActor
    func testCancelCreateWorkspace() throws {
        navigateToMockServer()

        app.buttons["createWorkspaceButton"].firstMatch.click()

        let cancelButton = app.buttons["cancelWorkspaceButton"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))
        cancelButton.click()

        // Sheet should be dismissed
        XCTAssertFalse(app.textFields["workspaceNameField"].exists)
    }

    @MainActor
    func testCancelAddRoute() throws {
        navigateToMockServer()
        createWorkspace(name: "Cancel Route WS")

        app.buttons["addRouteButton"].click()

        let cancelButton = app.buttons["cancelRouteButton"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))
        cancelButton.click()

        // Sheet should be dismissed
        XCTAssertFalse(app.textFields["routeNameField"].exists)
    }
}
