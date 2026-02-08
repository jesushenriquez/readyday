import Foundation

struct ClassifyEventDemandUseCase: Sendable {

    func classify(event: CalendarEvent) -> EnergyDemand {
        var score: Double = 0

        // Factor 1: Duration (0-3 points)
        let hours = event.durationHours
        if hours >= 2.0 {
            score += 3
        } else if hours >= 1.0 {
            score += 2
        } else {
            score += 1
        }

        // Factor 2: Attendees (0-3 points)
        let attendeeCount = event.attendeeCount
        if attendeeCount >= 8 {
            score += 3
        } else if attendeeCount >= 4 {
            score += 2
        } else if attendeeCount >= 1 {
            score += 1
        }

        // Factor 3: Time of day — post-lunch dip (0-1 points)
        let hour = Calendar.current.component(.hour, from: event.startDate)
        if hour >= 13 && hour <= 15 {
            score += 1
        }

        // Factor 4: Title keywords (0-2 points)
        let title = event.title.lowercased()
        let highDemandKeywords = [
            "strategy", "review", "presentation", "interview",
            "planning", "brainstorm", "board", "all-hands",
            "pitch", "demo", "retrospective", "quarterly"
        ]
        let lowDemandKeywords = [
            "lunch", "break", "coffee", "social", "happy hour",
            "walk", "1:1", "check-in", "standup", "daily"
        ]

        if highDemandKeywords.contains(where: { title.contains($0) }) {
            score += 2
        } else if lowDemandKeywords.contains(where: { title.contains($0) }) {
            score -= 1
        }

        // Classification
        if score >= 6 {
            return .high
        } else if score >= 3 {
            return .medium
        } else {
            return .low
        }
    }

    func classifyAll(events: [CalendarEvent]) -> [ClassifiedEvent] {
        events.map { event in
            ClassifiedEvent(event: event, demand: classify(event: event))
        }
    }
}
