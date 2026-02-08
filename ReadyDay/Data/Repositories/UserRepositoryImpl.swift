import Foundation

final class UserRepositoryImpl: UserRepository, @unchecked Sendable {
    private let supabaseManager: SupabaseManager
    private let userDefaults: UserDefaultsServiceProtocol

    init(
        supabaseManager: SupabaseManager = .shared,
        userDefaults: UserDefaultsServiceProtocol = UserDefaultsService()
    ) {
        self.supabaseManager = supabaseManager
        self.userDefaults = userDefaults
    }

    func getCurrentUserId() async -> UUID? {
        // TODO: Implement in Sprint 1 — get from Supabase auth session
        nil
    }

    func isOnboardingCompleted() async -> Bool {
        userDefaults.bool(for: UserDefaultsService.Key.onboardingCompleted)
    }

    func setOnboardingCompleted() async throws {
        userDefaults.set(true, for: UserDefaultsService.Key.onboardingCompleted)
    }

    func getUserDisplayName() async -> String? {
        // TODO: Implement in Sprint 1
        nil
    }

    func getMorningBriefingTime() async -> Date? {
        // TODO: Implement in Sprint 2
        nil
    }

    func setMorningBriefingTime(_ time: Date) async throws {
        // TODO: Implement in Sprint 2
    }
}
