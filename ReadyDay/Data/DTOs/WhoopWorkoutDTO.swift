import Foundation

struct WhoopWorkoutDTO: Codable, Sendable {
    let id: String
    let userId: Int64
    let start: String
    let end: String
    let sportId: Int?
    let scoreState: String
    let score: ScoreDTO?

    struct ScoreDTO: Codable, Sendable {
        let strain: Double?
        let averageHeartRate: Int?
        let maxHeartRate: Int?
        let kilojoule: Double?
        let distanceMeter: Double?
        let zoneDuration: ZoneDurationDTO?

        struct ZoneDurationDTO: Codable, Sendable {
            let zoneFiveMilli: Int64?
            let zoneFourMilli: Int64?
            let zoneThreeMilli: Int64?
            let zoneTwoMilli: Int64?
            let zoneOneMilli: Int64?
            let zoneZeroMilli: Int64?

            enum CodingKeys: String, CodingKey {
                case zoneFiveMilli = "zone_five_milli"
                case zoneFourMilli = "zone_four_milli"
                case zoneThreeMilli = "zone_three_milli"
                case zoneTwoMilli = "zone_two_milli"
                case zoneOneMilli = "zone_one_milli"
                case zoneZeroMilli = "zone_zero_milli"
            }
        }

        enum CodingKeys: String, CodingKey {
            case strain
            case averageHeartRate = "average_heart_rate"
            case maxHeartRate = "max_heart_rate"
            case kilojoule
            case distanceMeter = "distance_meter"
            case zoneDuration = "zone_duration"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case start, end
        case sportId = "sport_id"
        case scoreState = "score_state"
        case score
    }
}

extension WhoopWorkoutDTO {
    func toDomain() -> WorkoutData {
        let formatter = ISO8601DateFormatter()

        let zones: ZoneDurations? = score?.zoneDuration.map { z in
            ZoneDurations(
                zone0Millis: z.zoneZeroMilli ?? 0,
                zone1Millis: z.zoneOneMilli ?? 0,
                zone2Millis: z.zoneTwoMilli ?? 0,
                zone3Millis: z.zoneThreeMilli ?? 0,
                zone4Millis: z.zoneFourMilli ?? 0,
                zone5Millis: z.zoneFiveMilli ?? 0
            )
        }

        return WorkoutData(
            workoutId: UUID(uuidString: id) ?? UUID(),
            sportName: nil,
            startTime: formatter.date(from: start) ?? Date(),
            endTime: formatter.date(from: end) ?? Date(),
            scoreState: ScoreState(rawValue: scoreState) ?? .unscorable,
            strain: score?.strain,
            averageHeartRate: score?.averageHeartRate,
            maxHeartRate: score?.maxHeartRate,
            kilojoule: score?.kilojoule,
            distanceMeter: score?.distanceMeter,
            zoneDurations: zones,
            recordedAt: formatter.date(from: start) ?? Date()
        )
    }
}
