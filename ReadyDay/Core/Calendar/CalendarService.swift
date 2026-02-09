import EventKit
import Foundation

protocol CalendarServiceProtocol: Sendable {
    func requestAccess() async throws -> Bool
    func getEvents(for date: Date, calendarIDs: [String]?) async throws -> [EKEvent]
    func getCalendars() -> [EKCalendar]
    func findGaps(for date: Date, minDuration: TimeInterval) async throws -> [TimeWindow]
}

final class CalendarService: CalendarServiceProtocol, @unchecked Sendable {
    private let eventStore = EKEventStore()

    func requestAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToEvents()
    }

    private func ensureFullAccess() async throws {
        let status = CalendarPermissionStatus.current
        switch status {
        case .fullAccess:
            return
        case .notDetermined:
            let granted = try await eventStore.requestFullAccessToEvents()
            if !granted { throw ReadyDayError.calendarAccessDenied }
        case .writeOnly, .denied:
            throw ReadyDayError.calendarAccessDenied
        case .restricted:
            throw ReadyDayError.calendarAccessRestricted
        }
    }

    func getEvents(for date: Date, calendarIDs: [String]? = nil) async throws -> [EKEvent] {
        try await ensureFullAccess()

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

    func findGaps(for date: Date, minDuration: TimeInterval = 3600) async throws -> [TimeWindow] {
        let events = try await getEvents(for: date)

        // Define working hours (8 AM - 10 PM)
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let workDayStart = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: startOfDay),
              let workDayEnd = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startOfDay) else {
            return []
        }

        // Filter out all-day events and sort by start time
        let timedEvents = events
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }

        var gaps: [TimeWindow] = []
        var currentEnd = workDayStart

        for event in timedEvents {
            let eventStart = max(event.startDate, workDayStart)
            let eventEnd = min(event.endDate, workDayEnd)

            // Check if there's a gap before this event
            if currentEnd < eventStart {
                let gapDuration = eventStart.timeIntervalSince(currentEnd)
                if gapDuration >= minDuration {
                    gaps.append(TimeWindow(start: currentEnd, end: eventStart))
                }
            }

            // Update current end if this event extends beyond it
            if eventEnd > currentEnd {
                currentEnd = eventEnd
            }
        }

        // Check for gap after last event until end of work day
        if currentEnd < workDayEnd {
            let gapDuration = workDayEnd.timeIntervalSince(currentEnd)
            if gapDuration >= minDuration {
                gaps.append(TimeWindow(start: currentEnd, end: workDayEnd))
            }
        }

        return gaps
    }
}
