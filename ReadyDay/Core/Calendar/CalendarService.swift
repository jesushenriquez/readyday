import EventKit
import Foundation

protocol CalendarServiceProtocol: Sendable {
    func requestAccess() async throws -> Bool
    func getEvents(for date: Date, calendarIDs: [String]?) -> [EKEvent]
    func getCalendars() -> [EKCalendar]
    func findGaps(for date: Date, minDuration: TimeInterval) -> [TimeWindow]
}

final class CalendarService: CalendarServiceProtocol, @unchecked Sendable {
    private let eventStore = EKEventStore()

    func requestAccess() async throws -> Bool {
        // TODO: Implement full calendar access request in Sprint 1
        try await eventStore.requestFullAccessToEvents()
    }

    func getEvents(for date: Date, calendarIDs: [String]? = nil) -> [EKEvent] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let calendars: [EKCalendar]?
        if let ids = calendarIDs {
            calendars = eventStore.calendars(for: .event).filter { ids.contains($0.calendarIdentifier) }
        } else {
            calendars = nil
        }

        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: calendars
        )
        return eventStore.events(matching: predicate)
    }

    func getCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }

    func findGaps(for date: Date, minDuration: TimeInterval = 3600) -> [TimeWindow] {
        // TODO: Implement gap finding in Sprint 1
        []
    }
}
