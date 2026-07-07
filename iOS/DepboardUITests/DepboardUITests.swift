import XCTest

final class DepboardUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddEntryFlow() {
        app.buttons["addEntryButton"].tap()
        let field1 = app.textFields["field1Input"]
        XCTAssertTrue(field1.waitForExistence(timeout: 2))
        field1.tap()
        field1.typeText("New Entry")
        app.buttons["saveEntryButton"].tap()
        XCTAssertTrue(app.staticTexts["New Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<(8+2) {
            let addButton = app.buttons["addEntryButton"]
            if addButton.exists { addButton.tap() }
            let field1 = app.textFields["field1Input"]
            if field1.waitForExistence(timeout: 2) {
                field1.tap()
                field1.typeText("Entry \(i)")
                app.buttons["saveEntryButton"].tap()
            } else {
                break
            }
        }
        XCTAssertTrue(app.buttons["purchaseButton"].waitForExistence(timeout: 3) || app.staticTexts["Departure Board Pro"].waitForExistence(timeout: 3))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addEntryButton"].tap()
        let field1 = app.textFields["field1Input"]
        XCTAssertTrue(field1.waitForExistence(timeout: 2))
        field1.tap()
        field1.typeText("Dismiss Me")
        app.navigationBars.staticTexts.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }
}
