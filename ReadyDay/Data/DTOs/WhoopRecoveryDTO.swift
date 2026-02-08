import Foundation

struct WhoopRecoveryDTO: Codable, Sendable {
    let cycleId: Int64
    let sleepId: String?
    let userId: Int64
    let scoreState: String
    let score: ScoreDTO?
    let createdAt: String

    struct ScoreDTO: Codable, Sendable {
        let userCalibrating: Bool
        let recoveryScore: Int
        let restingHeartRate: Double
        let hrvRmssdMilli: Double
        let spo2Percentage: Double?
        let skinTempCelsius: Double?

        enum CodingKeys: String, CodingKey {
            case userCalibrating = "user_calibrating"
            case recoveryScore = "recovery_score"
            case restingHeartRate = "resting_heart_rate"
            case hrvRmssdMilli = "hrv_rmssd_milli"
            case spo2Percentage = "spo2_percentage"
            case skinTempCelsius = "skin_temp_celsius"
        }
    }

    enum CodingKeys: String, CodingKey {
        case cycleId = "cycle_id"
        case sleepId = "sleep_id"
        case userId = "user_id"
        case scoreState = "score_state"
        case score
        case createdAt = "created_at"
    }
}

extension WhoopRecoveryDTO {
    func toDomain() -> RecoveryData {
        RecoveryData(
            cycleId: cycleId,
            sleepId: sleepId.flatMap(UUID.init),
            scoreState: ScoreState(rawValue: scoreState) ?? .unscorable,
            recoveryScore: score?.recoveryScore,
            restingHeartRate: score?.restingHeartRate,
            hrvRmssdMilli: score?.hrvRmssdMilli,
            spo2Percentage: score?.spo2Percentage,
            skinTempCelsius: score?.skinTempCelsius,
            isCalibrating: score?.userCalibrating ?? false,
            recordedAt: ISO8601DateFormatter().date(from: createdAt) ?? Date()
        )
    }
}
