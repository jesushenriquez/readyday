import Foundation
import AuthenticationServices

protocol WhoopOAuthManagerProtocol: Sendable {
    func getValidToken() async throws -> String
    func startOAuthFlow() async throws
    func isConnected() async -> Bool
    func disconnect() async throws
}

@Observable
@MainActor
final class WhoopOAuthManager: WhoopOAuthManagerProtocol, @unchecked Sendable {

    private(set) var isAuthenticated = false

    func getValidToken() async throws -> String {
        // TODO: Implement in Sprint 1
        // 1. Check Keychain for access token
        // 2. If expired, use refresh token
        // 3. If refresh fails, prompt re-auth
        throw ReadyDayError.whoopTokenExpired
    }

    func startOAuthFlow() async throws {
        // TODO: Implement in Sprint 1 using ASWebAuthenticationSession
    }

    func refreshToken() async throws {
        // TODO: Implement in Sprint 1
        // POST to token URL with refresh_token grant
    }

    func isConnected() async -> Bool {
        // TODO: Check for valid stored tokens
        false
    }

    func disconnect() async throws {
        // TODO: Clear tokens from Keychain and Supabase
        isAuthenticated = false
    }
}
