import Foundation

enum RecommendationType: String, Codable, Sendable {
    case warning
    case calendar
    case workout
    case sleep
    case positive
    case info

    var iconName: String {
        switch self {
        case .warning: "exclamationmark.triangle.fill"
        case .calendar: "calendar.badge.clock"
        case .workout: "figure.run"
        case .sleep: "bed.double.fill"
        case .positive: "checkmark.seal.fill"
        case .info: "lightbulb.fill"
        }
    }
}

enum RecommendationPriority: Int, Codable, Sendable, Comparable {
    case low = 0
    case medium = 1
    case high = 2

    static func < (lhs: RecommendationPriority, rhs: RecommendationPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct Recommendation: Identifiable, Sendable {
    let id: UUID
    let type: RecommendationType
    let title: String
    let body: String
    let priority: RecommendationPriority

    init(
        id: UUID = UUID(),
        type: RecommendationType,
        title: String,
        body: String,
        priority: RecommendationPriority
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.priority = priority
    }
}
