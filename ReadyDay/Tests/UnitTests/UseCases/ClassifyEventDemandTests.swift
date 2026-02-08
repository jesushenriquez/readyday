import XCTest
@testable import ReadyDay

final class ClassifyEventDemandTests: XCTestCase {

    private var sut: ClassifyEventDemandUseCase!

    override func setUp() {
        super.setUp()
        sut = ClassifyEventDemandUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // TODO: Add tests in Sprint 1
    // - Test short, no-attendee event → low
    // - Test long meeting with many attendees → high
    // - Test event with high-demand keywords → high
    // - Test event with low-demand keywords → low
    // - Test post-lunch time bonus

    func testPlaceholder() {
        XCTAssertNotNil(sut)
    }
}
