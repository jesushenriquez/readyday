import Foundation

struct CalendarEvent: Identifiable, Sendable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let attendeeCount: Int
    let calendarName: String?
    let isAllDay: Bool

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    var durationHours: Double {
        duration / 3600
    }
}

struct ClassifiedEvent: Identifiable, Sendable {
    let event: CalendarEvent
    let demand: EnergyDemand

    var id: String { event.id }
    var title: String { event.title }
    var startDate: Date { event.startDate }
    var endDate: Date { event.endDate }
    var duration: TimeInterval { event.duration }
}
