import XCTest
@testable import ReadyDay

@MainActor
final class BriefingViewModelTests: XCTestCase {

    // TODO: Add tests in Sprint 1
    // - Test initial state is empty
    // - Test loading sets isLoading true
    // - Test successful load populates briefing
    // - Test error handling sets error

    func testInitialState() {
        let viewModel = BriefingViewModel()
        XCTAssertNil(viewModel.briefing)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
}
