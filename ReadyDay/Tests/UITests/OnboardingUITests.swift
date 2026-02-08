import XCTest

final class OnboardingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // TODO: Add UI tests in Sprint 2
    // - Test onboarding flow navigation
    // - Test skip Whoop button works
    // - Test calendar permission screen shows

    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
