import Foundation

enum ScoreState: String, Codable, Sendable {
    case scored = "SCORED"
    case pendingScore = "PENDING_SCORE"
    case unscorable = "UNSCORABLE"
}

enum RecoveryZone: String, Codable, Sendable {
    case green
    case yellow
    case red
    case unknown

    static func from(score: Int?) -> RecoveryZone {
        guard let score else { return .unknown }
        switch score {
        case 67...100: return .green
        case 34...66: return .yellow
        case 0...33: return .red
        default: return .unknown
        }
    }

    var label: String {
        switch self {
        case .green: "Ready"
        case .yellow: "Moderate"
        case .red: "Low"
        case .unknown: "Unknown"
        }
    }
}

struct RecoveryData: Sendable {
    let cycleId: Int64
    let sleepId: UUID?
    let scoreState: ScoreState
    let recoveryScore: Int?
    let restingHeartRate: Double?
    let hrvRmssdMilli: Double?
    let spo2Percentage: Double?
    let skinTempCelsius: Double?
    let isCalibrating: Bool
    let recordedAt: Date

    var zone: RecoveryZone {
        RecoveryZone.from(score: recoveryScore)
    }
}
