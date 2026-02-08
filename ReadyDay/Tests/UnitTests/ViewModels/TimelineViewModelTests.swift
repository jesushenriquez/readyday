import XCTest
@testable import ReadyDay

@MainActor
final class TimelineViewModelTests: XCTestCase {

    // TODO: Add tests in Sprint 1
    // - Test initial state
    // - Test date navigation
    // - Test event loading

    func testInitialState() {
        let viewModel = TimelineViewModel()
        XCTAssertTrue(viewModel.events.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
}
