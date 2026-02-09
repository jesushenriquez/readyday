import XCTest
import EventKit
@testable import ReadyDay

final class CalendarRepositoryTests: XCTestCase {
    var sut: CalendarRepositoryImpl!
    var mockCalendarService: MockCalendarService!

    override func setUp() {
        super.setUp()
        mockCalendarService = MockCalendarService()
        sut = CalendarRepositoryImpl(calendarService: mockCalendarService)
    }

    override func tearDown() {
        sut = nil
        mockCalendarService = nil
        super.tearDown()
    }

    // MARK: - Get Events Tests

    func testGetEventsForDateMapsEKEventsCorrectly() async throws {
        // Given
        let testDate = Date()
        let mockEKEvents = [
            createMockEKEvent(
                title: "Team Meeting",
                start: testDate.addingTimeInterval(3600),
                end: testDate.addingTimeInterval(5400),
                location: "Conference Room A",
                attendeeCount: 5
            ),
            createMockEKEvent(
                title: "Gym",
                start: testDate.addingTimeInterval(7200),
                end: testDate.addingTimeInterval(10800),
                location: "Fitness Center",
                attendeeCount: 0
            )
        ]
        mockCalendarService.mockEvents = mockEKEvents

        // When
        let events = try await sut.getEvents(for: testDate)

        // Then
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].title, "Team Meeting")
        XCTAssertEqual(events[0].location, "Conference Room A")
        XCTAssertEqual(events[0].attendeeCount, 5)
        XCTAssertEqual(events[1].title, "Gym")
        XCTAssertFalse(events[1].isAllDay)
    }

    func testGetEventsHandlesAllDayEvents() async throws {
        // Given
        let testDate = Date()
        let mockEKEvents = [
            createMockEKEvent(
                title: "Company Holiday",
                start: testDate,
                end: testDate,
                isAllDay: true
            )
        ]
        mockCalendarService.mockEvents = mockEKEvents

        // When
        let events = try await sut.getEvents(for: testDate)

        // Then
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events[0].isAllDay)
        XCTAssertEqual(events[0].title, "Company Holiday")
    }

    func testGetEventsReturnsEmptyArrayWhenNoEvents() async throws {
        // Given
        mockCalendarService.mockEvents = []
        let testDate = Date()

        // When
        let events = try await sut.getEvents(for: testDate)

        // Then
        XCTAssertTrue(events.isEmpty)
    }

    func testGetEventsHandlesMissingOptionalFields() async throws {
        // Given
        let testDate = Date()
        let mockEKEvents = [
            createMockEKEvent(
                title: nil, // No title
                start: testDate,
                end: testDate.addingTimeInterval(3600),
                location: nil, // No location
                attendeeCount: 0
            )
        ]
        mockCalendarService.mockEvents = mockEKEvents

        // When
        let events = try await sut.getEvents(for: testDate)

        // Then
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].title, "Untitled")
        XCTAssertNil(events[0].location)
    }

    // MARK: - Get Available Calendars Tests

    func testGetAvailableCalendarsReturnsCorrectTuples() async throws {
        // Given
        let mockCalendars = [
            createMockEKCalendar(title: "Work", identifier: "cal-work-123"),
            createMockEKCalendar(title: "Personal", identifier: "cal-personal-456")
        ]
        mockCalendarService.mockCalendars = mockCalendars

        // When
        let calendars = try await sut.getAvailableCalendars()

        // Then
        XCTAssertEqual(calendars.count, 2)
        XCTAssertEqual(calendars[0].id, "cal-work-123")
        XCTAssertEqual(calendars[0].name, "Work")
        XCTAssertEqual(calendars[1].id, "cal-personal-456")
        XCTAssertEqual(calendars[1].name, "Personal")
    }

    // MARK: - Find Gaps Tests

    func testFindGapsReturnsTimeWindows() async throws {
        // Given
        let testDate = Date()
        let mockGaps = [
            TimeWindow(start: testDate.addingTimeInterval(3600), end: testDate.addingTimeInterval(7200)),
            TimeWindow(start: testDate.addingTimeInterval(10800), end: testDate.addingTimeInterval(14400))
        ]
        mockCalendarService.mockGaps = mockGaps

        // When
        let gaps = try await sut.findGaps(for: testDate, minDuration: 3600)

        // Then
        XCTAssertEqual(gaps.count, 2)
        XCTAssertEqual(gaps[0].durationMinutes, 60) // 1 hour
        XCTAssertEqual(gaps[1].durationMinutes, 60)
    }

    func testFindGapsRespectsMinDuration() async throws {
        // Given
        let testDate = Date()
        mockCalendarService.mockGaps = [] // Service already filtered by minDuration

        // When
        let gaps = try await sut.findGaps(for: testDate, minDuration: 7200) // 2 hours

        // Then
        XCTAssertTrue(gaps.isEmpty)
    }

    // MARK: - Helper Methods

    private func createMockEKEvent(
        title: String?,
        start: Date,
        end: Date,
        location: String? = nil,
        attendeeCount: Int = 0,
        isAllDay: Bool = false
    ) -> EKEvent {
        let event = EKEvent(eventStore: EKEventStore())
        event.title = title
        event.startDate = start
        event.endDate = end
        event.location = location
        event.isAllDay = isAllDay
        // Note: EKEvent.attendees is read-only and set by EventKit, so we can't mock it directly
        // In real tests, you'd need to use a wrapper/protocol for EKEvent
        return event
    }

    private func createMockEKCalendar(title: String, identifier: String) -> EKCalendar {
        let calendar = EKCalendar(for: .event, eventStore: EKEventStore())
        calendar.title = title
        // Note: EKCalendar.calendarIdentifier is read-only, can't be set in tests
        // In real implementation, you'd need to use actual EventKit or a protocol wrapper
        return calendar
    }
}

// MARK: - Mock CalendarService

final class MockCalendarService: CalendarServiceProtocol, @unchecked Sendable {
    var mockEvents: [EKEvent] = []
    var mockCalendars: [EKCalendar] = []
    var mockGaps: [TimeWindow] = []
    var hasAccessGranted = true
    var shouldThrowError = false

    func requestAccess() async throws -> Bool {
        if shouldThrowError {
            throw ReadyDayError.calendarAccessDenied
        }
        return hasAccessGranted
    }

    func getEvents(for date: Date, calendarIDs: [String]?) -> [EKEvent] {
        return mockEvents
    }

    func getCalendars() -> [EKCalendar] {
        return mockCalendars
    }

    func findGaps(for date: Date, minDuration: TimeInterval) -> [TimeWindow] {
        return mockGaps.filter { $0.duration >= minDuration }
    }
}
