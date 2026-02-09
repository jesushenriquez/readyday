import XCTest
@testable import ReadyDay

@MainActor
final class BriefingViewModelTests: XCTestCase {

    var sut: BriefingViewModel!
    var mockWhoopRepository: MockWhoopRepository!
    var mockCalendarRepository: MockCalendarRepository!
    var mockUserRepository: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockWhoopRepository = MockWhoopRepository()
        mockCalendarRepository = MockCalendarRepository()
        mockUserRepository = MockUserRepository()

        let classifyUseCase = ClassifyEventDemandUseCase()
        let findWorkoutUseCase = FindWorkoutWindowUseCase(calendarRepo: mockCalendarRepository)
        let generateBriefingUseCase = GenerateBriefingUseCase(
            whoopRepo: mockWhoopRepository,
            calendarRepo: mockCalendarRepository,
            classifyDemand: classifyUseCase,
            findWorkoutWindow: findWorkoutUseCase
        )
        let syncUseCase = SyncWhoopDataUseCase(whoopRepo: mockWhoopRepository)

        sut = BriefingViewModel(
            generateBriefingUseCase: generateBriefingUseCase,
            syncWhoopDataUseCase: syncUseCase,
            userRepository: mockUserRepository
        )
    }

    override func tearDown() {
        sut = nil
        mockWhoopRepository = nil
        mockCalendarRepository = nil
        mockUserRepository = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertNil(sut.briefing)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
}
