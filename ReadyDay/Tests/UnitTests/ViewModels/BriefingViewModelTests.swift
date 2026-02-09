import XCTest
@testable import ReadyDay

@MainActor
final class BriefingViewModelTests: XCTestCase {

    var sut: BriefingViewModel!
    var mockWhoopRepository: MockWhoopRepository!
    var mockCalendarRepository: MockCalendarRepository!
    var classifyEventDemandUseCase: ClassifyEventDemandUseCase!

    override func setUp() {
        super.setUp()
        mockWhoopRepository = MockWhoopRepository()
        mockCalendarRepository = MockCalendarRepository()
        classifyEventDemandUseCase = ClassifyEventDemandUseCase()
        sut = BriefingViewModel(
            whoopRepository: mockWhoopRepository,
            calendarRepository: mockCalendarRepository,
            classifyEventDemandUseCase: classifyEventDemandUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockWhoopRepository = nil
        mockCalendarRepository = nil
        classifyEventDemandUseCase = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertNil(sut.briefing)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
}
