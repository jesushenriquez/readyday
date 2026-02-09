import XCTest
@testable import ReadyDay

final class ClassifyEventDemandTests: XCTestCase {
    var sut: ClassifyEventDemandUseCase!

    override func setUp() {
        super.setUp()
        sut = ClassifyEventDemandUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - High Demand Tests

    func testClassifiesHighDemandMeetings() {
        // Given - meetings, presentations, interviews
        let highDemandTitles = [
            "Board Meeting",
            "Client Presentation",
            "Job Interview",
            "Performance Review",
            "Quarterly Planning Meeting",
            "Executive Strategy Session",
            "Investor Pitch",
            "Team Workshop"
        ]

        // When/Then
        for title in highDemandTitles {
            let event = createEvent(title: title)
            let demand = sut.classify(event: event)
            XCTAssertEqual(demand, EnergyDemand.high, "\(title) should be classified as high demand")
        }
    }

    func testClassifiesHighDemandWithMultipleAttendees() {
        // Given - 5+ attendees
        let event = createEvent(title: "Team Sync", attendeeCount: 8)

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.high)
    }

    func testClassifiesHighDemandWorkouts() {
        // Given - intense workout keywords
        let workoutTitles = [
            "HIIT Training",
            "CrossFit WOD",
            "Marathon Training",
            "Competition Prep",
            "Sparring Session",
            "Race Day"
        ]

        // When/Then
        for title in workoutTitles {
            let event = createEvent(title: title)
            let demand = sut.classify(event: event)
            XCTAssertEqual(demand, EnergyDemand.high, "\(title) should be classified as high demand")
        }
    }

    // MARK: - Medium Demand Tests

    func testClassifiesMediumDemandActivities() {
        // Given - moderate activities
        let mediumDemandTitles = [
            "Gym Session",
            "Yoga Class",
            "Team Standup",
            "1:1 with Manager",
            "Code Review",
            "Lunch Meeting",
            "Coffee Chat",
            "Doctor Appointment"
        ]

        // When/Then
        for title in mediumDemandTitles {
            let event = createEvent(title: title)
            let demand = sut.classify(event: event)
            XCTAssertEqual(demand, EnergyDemand.medium, "\(title) should be classified as medium demand")
        }
    }

    func testClassifiesMediumDemandWithModerateAttendees() {
        // Given - 2-4 attendees
        let event = createEvent(title: "Project Sync", attendeeCount: 3)

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.medium)
    }

    func testClassifiesMediumDemandLongEvents() {
        // Given - event over 2 hours
        let event = createEvent(title: "Training Session", durationHours: 2.5)

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.medium)
    }

    // MARK: - Low Demand Tests

    func testClassifiesLowDemandActivities() {
        // Given - passive or restful activities
        let lowDemandTitles = [
            "Break",
            "Lunch",
            "Walk",
            "Reading Time",
            "Focus Time",
            "Admin Work",
            "Email Catch-up",
            "Planning Time"
        ]

        // When/Then
        for title in lowDemandTitles {
            let event = createEvent(title: title)
            let demand = sut.classify(event: event)
            XCTAssertEqual(demand, EnergyDemand.low, "\(title) should be classified as low demand")
        }
    }

    func testClassifiesLowDemandSoloEvents() {
        // Given - no attendees
        let event = createEvent(title: "Deep Work", attendeeCount: 0)

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.low)
    }

    func testClassifiesLowDemandShortEvents() {
        // Given - short event (30 minutes)
        let event = createEvent(title: "Quick Check-in", durationHours: 0.5)

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.low)
    }

    // MARK: - Edge Cases

    func testClassifiesEmptyTitle() {
        // Given - empty title
        let event = createEvent(title: "")

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.low, "Events with no title should default to low demand")
    }

    func testClassifiesUntitledEvent() {
        // Given - "Untitled" event
        let event = createEvent(title: "Untitled")

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.low, "Untitled events should default to low demand")
    }

    func testClassifiesCaseInsensitive() {
        // Given - different case variations
        let variations = [
            "MEETING",
            "Meeting",
            "meeting",
            "MeEtInG"
        ]

        // When/Then
        for title in variations {
            let event = createEvent(title: title)
            let demand = sut.classify(event: event)
            XCTAssertEqual(demand, EnergyDemand.high, "Classification should be case-insensitive")
        }
    }

    func testClassifiesWithExtraWhitespace() {
        // Given - title with extra whitespace
        let event = createEvent(title: "  Board   Meeting  ")

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.high, "Should handle whitespace in titles")
    }

    func testClassifiesAllDayEvents() {
        // Given - all-day event
        let event = CalendarEvent(
            id: "test-id",
            title: "Conference",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            location: nil,
            attendeeCount: 0,
            calendarName: nil,
            isAllDay: true
        )

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.medium, "All-day events should be at least medium demand")
    }

    func testPrioritizesHighDemandKeywordsOverAttendees() {
        // Given - high demand keyword with few attendees
        let event = createEvent(title: "Interview", attendeeCount: 1)

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.high, "Keyword matching should take priority")
    }

    func testClassifiesMultipleKeywords() {
        // Given - title with both high and low demand keywords
        let event = createEvent(title: "Lunch Meeting with Client")

        // When
        let demand = sut.classify(event: event)

        // Then
        // Should prioritize highest demand keyword found
        XCTAssertEqual(demand, EnergyDemand.high, "Should use highest demand keyword when multiple are present")
    }

    func testClassifiesEventsWithNumbers() {
        // Given - title with numbers
        let event = createEvent(title: "Q4 2024 Board Meeting")

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.high, "Should handle numbers in titles")
    }

    func testClassifiesEventsWithSpecialCharacters() {
        // Given - title with special characters
        let event = createEvent(title: "1:1 Review (Manager)")

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.medium, "Should handle special characters")
    }

    func testClassifiesVeryLongEvents() {
        // Given - 4+ hour event
        let event = createEvent(title: "All Hands", durationHours: 4)

        // When
        let demand = sut.classify(event: event)

        // Then
        XCTAssertEqual(demand, EnergyDemand.high, "Very long events should be high demand")
    }

    func testClassifiesTravelEvents() {
        // Given - travel keywords
        let travelTitles = [
            "Flight to NYC",
            "Travel Day",
            "Commute to Office",
            "Drive to Conference"
        ]

        // When/Then
        for title in travelTitles {
            let event = createEvent(title: title)
            let demand = sut.classify(event: event)
            XCTAssertTrue([EnergyDemand.medium, EnergyDemand.high].contains(demand), "\(title) should be medium or high demand")
        }
    }

    // MARK: - Helper Methods

    private func createEvent(
        title: String,
        attendeeCount: Int = 0,
        durationHours: Double = 1.0
    ) -> CalendarEvent {
        let start = Date()
        let end = start.addingTimeInterval(durationHours * 3600)
        return CalendarEvent(
            id: UUID().uuidString,
            title: title,
            startDate: start,
            endDate: end,
            location: nil,
            attendeeCount: attendeeCount,
            calendarName: nil,
            isAllDay: false
        )
    }
}
