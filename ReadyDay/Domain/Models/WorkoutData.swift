import Foundation

struct ZoneDurations: Sendable {
    let zone0Millis: Int64
    let zone1Millis: Int64
    let zone2Millis: Int64
    let zone3Millis: Int64
    let zone4Millis: Int64
    let zone5Millis: Int64
}

struct WorkoutData: Sendable {
    let workoutId: UUID
    let sportName: String?
    let startTime: Date
    let endTime: Date
    let scoreState: ScoreState
    let strain: Double?
    let averageHeartRate: Int?
    let maxHeartRate: Int?
    let kilojoule: Double?
    let distanceMeter: Double?
    let zoneDurations: ZoneDurations?
    let recordedAt: Date

    var durationMinutes: Double {
        endTime.timeIntervalSince(startTime) / 60
    }

    var formattedDuration: String {
        let total = endTime.timeIntervalSince(startTime)
        let hours = Int(total / 3600)
        let minutes = Int(total.truncatingRemainder(dividingBy: 3600) / 60)
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
