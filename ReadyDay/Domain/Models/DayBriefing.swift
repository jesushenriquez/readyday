import Foundation

struct TimeWindow: Sendable {
    let start: Date
    let end: Date

    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    var durationMinutes: Int {
        Int(duration / 60)
    }
}

struct SleepSummary: Sendable {
    let totalHours: Double
    let efficiency: Double?
    let stages: StageSummary?
    let formattedDuration: String

    init(from sleep: SleepData) {
        self.totalHours = sleep.totalDurationHours
        self.efficiency = sleep.sleepEfficiency
        self.stages = sleep.stageSummary
        self.formattedDuration = sleep.formattedDuration
    }
}

struct DayBriefing: Sendable {
    let date: Date
    let recoveryZone: RecoveryZone
    let recoveryScore: Int
    let sleepSummary: SleepSummary
    let events: [ClassifiedEvent]
    let recommendations: [Recommendation]
    let calendarLoadScore: Double
    let suggestedWorkoutWindows: [TimeWindow]
}
