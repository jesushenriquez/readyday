import XCTest
import EventKit
@testable import ReadyDay

@MainActor
final class TimelineViewModelTests: XCTestCase {

    var sut: TimelineViewModel!
    var mockCalendarRepository: MockCalendarRepository!
    var classifyEventDemandUseCase: ClassifyEventDemandUseCase!

    override func setUp() {
        super.setUp()
        mockCalendarRepository = MockCalendarRepository()
        classifyEventDemandUseCase = ClassifyEventDemandUseCase()
        sut = TimelineViewModel(
            calendarRepository: mockCalendarRepository,
            classifyEventDemandUseCase: classifyEventDemandUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockCalendarRepository = nil
        classifyEventDemandUseCase = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertTrue(sut.events.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
}
