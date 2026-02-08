import Foundation

protocol UserRepository: Sendable {
    func getCurrentUserId() async -> UUID?
    func isOnboardingCompleted() async -> Bool
    func setOnboardingCompleted() async throws
    func getUserDisplayName() async -> String?
    func getMorningBriefingTime() async -> Date?
    func setMorningBriefingTime(_ time: Date) async throws
}
