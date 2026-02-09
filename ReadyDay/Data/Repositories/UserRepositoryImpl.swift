import Foundation
import Supabase

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
        // Get user ID from Supabase auth session
        guard let session = try? await supabaseManager.client.auth.session else {
            return nil
        }

        // Look up the user row by auth ID to get the internal user ID
        do {
            let response = try await supabaseManager.client
                .from("users")
                .select()
                .eq("supabase_auth_id", value: session.user.id.uuidString)
                .limit(1)
                .execute()

            let data = response.data

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let users = try decoder.decode([UserRow].self, from: data)
            return users.first?.id
        } catch {
            return nil
        }
    }

    func isOnboardingCompleted() async -> Bool {
        userDefaults.bool(for: UserDefaultsService.Key.onboardingCompleted)
    }

    func setOnboardingCompleted() async throws {
        userDefaults.set(true, for: UserDefaultsService.Key.onboardingCompleted)

        // Also update the database
        guard let session = try? await supabaseManager.client.auth.session else {
            return
        }

        try await supabaseManager.client
            .from("users")
            .update(["onboarding_completed": true])
            .eq("supabase_auth_id", value: session.user.id.uuidString)
            .execute()
    }

    func getUserDisplayName() async -> String? {
        guard let session = try? await supabaseManager.client.auth.session else {
            return nil
        }

        do {
            let response = try await supabaseManager.client
                .from("users")
                .select()
                .eq("supabase_auth_id", value: session.user.id.uuidString)
                .limit(1)
                .execute()

            let data = response.data

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let users = try decoder.decode([UserRow].self, from: data)
            return users.first?.displayName
        } catch {
            return nil
        }
    }

    func getMorningBriefingTime() async -> Date? {
        // TODO: Implement in Sprint 2
        nil
    }

    func setMorningBriefingTime(_ time: Date) async throws {
        // TODO: Implement in Sprint 2
    }
}
