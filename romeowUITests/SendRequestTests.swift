//
//  SendRequestTests.swift
//  romeowUITests
//
//  Mirrors: .maestro/02_send_request.yaml
//  Send HTTP GET request and verify response appears
//

import XCTest

final class SendRequestTests: XCTestCase {

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
    func testSendGETRequestAndReceiveResponse() throws {
        // Type URL - use a fast test endpoint
        let urlField = app.textFields["urlTextField"]
        XCTAssertTrue(urlField.waitForExistence(timeout: 5))
        urlField.click()
        urlField.typeText("https://httpbin.org/get")

        // Verify method picker exists (default is GET)
        XCTAssertTrue(app.popUpButtons["httpMethodPicker"].exists)

        // Tap Send
        let sendButton = app.buttons["sendButton"]
        XCTAssertTrue(sendButton.isEnabled)
        sendButton.click()

        // Wait for response status code to appear (network call - longer timeout)
        let statusCode = app.staticTexts["responseStatusCode"]
        XCTAssertTrue(statusCode.waitForExistence(timeout: 30))

        // Verify response duration is shown
        let duration = app.staticTexts["responseDuration"]
        XCTAssertTrue(duration.exists)

        // Verify response body text is visible (body tab selected by default)
        let bodyText = app.staticTexts["responseBodyText"]
        XCTAssertTrue(bodyText.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSendButtonDisabledWhenURLEmpty() throws {
        // URL field should be empty on launch
        let sendButton = app.buttons["sendButton"]
        XCTAssertTrue(sendButton.waitForExistence(timeout: 5))

        // Send button should be disabled when URL is empty
        XCTAssertFalse(sendButton.isEnabled)
    }

    @MainActor
    func testEmptyResponseBarDisappearsAfterRequest() throws {
        // Verify empty response bar is shown initially
        let emptyBar = app.staticTexts["emptyResponseBar"]
        XCTAssertTrue(emptyBar.waitForExistence(timeout: 5))

        // Type URL and send
        let urlField = app.textFields["urlTextField"]
        urlField.click()
        urlField.typeText("https://httpbin.org/get")

        app.buttons["sendButton"].click()

        // Wait for response and verify empty bar is gone
        let statusCode = app.staticTexts["responseStatusCode"]
        XCTAssertTrue(statusCode.waitForExistence(timeout: 15))
        XCTAssertFalse(emptyBar.exists)
    }
}
