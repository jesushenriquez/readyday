import Foundation

struct StageSummary: Sendable {
    let lightMillis: Int64
    let deepMillis: Int64
    let remMillis: Int64
    let wakeMillis: Int64

    var lightHours: Double { Double(lightMillis) / 3_600_000 }
    var deepHours: Double { Double(deepMillis) / 3_600_000 }
    var remHours: Double { Double(remMillis) / 3_600_000 }
    var wakeHours: Double { Double(wakeMillis) / 3_600_000 }
}

struct SleepData: Sendable {
    let sleepId: UUID
    let startTime: Date
    let endTime: Date
    let isNap: Bool
    let scoreState: ScoreState
    let stageSummary: StageSummary?
    let sleepNeededMillis: Int64?
    let sleepDebtMillis: Int64?
    let sleepEfficiency: Double?
    let sleepConsistency: Double?
    let respiratoryRate: Double?
    let recordedAt: Date

    var totalDurationMillis: Int64 {
        Int64(endTime.timeIntervalSince(startTime) * 1000)
    }

    var totalDurationHours: Double {
        endTime.timeIntervalSince(startTime) / 3600
    }

    var formattedDuration: String {
        let total = endTime.timeIntervalSince(startTime)
        let hours = Int(total / 3600)
        let minutes = Int(total.truncatingRemainder(dividingBy: 3600) / 60)
        return "\(hours)h \(minutes)m"
    }
}
