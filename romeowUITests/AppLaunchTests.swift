//
//  AppLaunchTests.swift
//  romeowUITests
//
//  Mirrors: .maestro/01_app_launch.yaml
//  Verify app launches to REST API view by default
//

import XCTest

final class AppLaunchTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testAppLaunchShowsRESTAPIView() throws {
        // Verify URL bar elements are visible
        XCTAssertTrue(app.textFields["urlTextField"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.popUpButtons["httpMethodPicker"].exists)
        XCTAssertTrue(app.buttons["sendButton"].exists)
    }

    @MainActor
    func testAppLaunchShowsEmptyResponseBar() throws {
        // Empty response bar should be visible on first launch
        let emptyBar = app.staticTexts["emptyResponseBar"]
        XCTAssertTrue(emptyBar.waitForExistence(timeout: 5))
    }

    @MainActor
    func testFeatureSwitcherButtonExists() throws {
        let switcher = app.buttons["featureSwitcherButton"]
        XCTAssertTrue(switcher.waitForExistence(timeout: 5))
    }
}
