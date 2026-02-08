import Foundation

struct WhoopProfileDTO: Codable, Sendable {
    let userId: Int64
    let email: String?
    let firstName: String?
    let lastName: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case firstName = "first_name"
        case lastName = "last_name"
    }

    var displayName: String {
        [firstName, lastName]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
