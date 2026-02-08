import XCTest

final class BriefingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // TODO: Add UI tests in Sprint 2
    // - Test briefing view loads
    // - Test tab navigation works
    // - Test pull to refresh

    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
