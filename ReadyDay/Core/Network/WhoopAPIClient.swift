import Foundation

protocol WhoopAPIClientProtocol: Sendable {
    func getCycles(start: Date?, end: Date?, limit: Int) async throws -> [WhoopCycleDTO]
    func getRecoveries(start: Date?, end: Date?, limit: Int) async throws -> [WhoopRecoveryDTO]
    func getSleeps(start: Date?, end: Date?, limit: Int) async throws -> [WhoopSleepDTO]
    func getWorkouts(start: Date?, end: Date?, limit: Int) async throws -> [WhoopWorkoutDTO]
    func getProfile() async throws -> WhoopProfileDTO
}

final class WhoopAPIClient: WhoopAPIClientProtocol, Sendable {
    private let baseURL = Configuration.whoopAPIBaseURL
    private let oauthManager: WhoopOAuthManagerProtocol

    init(oauthManager: WhoopOAuthManagerProtocol) {
        self.oauthManager = oauthManager
    }

    func getCycles(start: Date? = nil, end: Date? = nil, limit: Int = 25) async throws -> [WhoopCycleDTO] {
        // TODO: Implement in Sprint 1
        []
    }

    func getRecoveries(start: Date? = nil, end: Date? = nil, limit: Int = 25) async throws -> [WhoopRecoveryDTO] {
        // TODO: Implement in Sprint 1
        []
    }

    func getSleeps(start: Date? = nil, end: Date? = nil, limit: Int = 25) async throws -> [WhoopSleepDTO] {
        // TODO: Implement in Sprint 1
        []
    }

    func getWorkouts(start: Date? = nil, end: Date? = nil, limit: Int = 25) async throws -> [WhoopWorkoutDTO] {
        // TODO: Implement in Sprint 1
        []
    }

    func getProfile() async throws -> WhoopProfileDTO {
        // TODO: Implement in Sprint 1
        throw ReadyDayError.whoopDataUnavailable
    }
}
