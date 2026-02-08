import Foundation

struct WhoopCycleDTO: Codable, Sendable {
    let id: Int64
    let userId: Int64
    let start: String
    let end: String?
    let scoreState: String
    let score: ScoreDTO?

    struct ScoreDTO: Codable, Sendable {
        let strain: Double?
        let kilojoule: Double?
        let averageHeartRate: Int?
        let maxHeartRate: Int?

        enum CodingKeys: String, CodingKey {
            case strain
            case kilojoule
            case averageHeartRate = "average_heart_rate"
            case maxHeartRate = "max_heart_rate"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case start, end
        case scoreState = "score_state"
        case score
    }
}
