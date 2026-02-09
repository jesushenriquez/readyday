import Foundation
import AuthenticationServices

protocol WhoopOAuthManagerProtocol: Sendable {
    func getValidToken() async throws -> String
    func startOAuthFlow() async throws
    func isConnected() async -> Bool
    func disconnect() async throws
}

// MARK: - Token Response Model

struct WhoopTokenResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String
    let scope: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case scope
    }
}

// MARK: - OAuth Manager

@Observable
@MainActor
final class WhoopOAuthManager: NSObject, WhoopOAuthManagerProtocol, @unchecked Sendable {

    private(set) var isAuthenticated = false
    private let keychainService: KeychainService
    private let supabaseManager: SupabaseManager
    private var currentAuthSession: ASWebAuthenticationSession?

    init(keychainService: KeychainService, supabaseManager: SupabaseManager = .shared) {
        self.keychainService = keychainService
        self.supabaseManager = supabaseManager
        super.init()
    }

    // MARK: - Public Methods

    func getValidToken() async throws -> String {
        // Load token and expiry from Keychain
        guard let accessToken = try keychainService.loadString(for: KeychainService.Key.whoopAccessToken),
              let expiryDate = try keychainService.loadDate(for: KeychainService.Key.whoopTokenExpiry) else {
            throw ReadyDayError.whoopTokenExpired
        }

        // Check if token is still valid (with 5 minute buffer)
        let bufferTime: TimeInterval = 5 * 60
        if expiryDate.timeIntervalSinceNow > bufferTime {
            return accessToken
        }

        // Token expired or expiring soon, refresh it
        try await refreshToken()

        // Return the new token
        guard let newToken = try keychainService.loadString(for: KeychainService.Key.whoopAccessToken) else {
            throw ReadyDayError.whoopTokenExpired
        }

        return newToken
    }

    func startOAuthFlow() async throws {
        // Generate random state for CSRF protection
        let state = generateRandomState()
        try keychainService.saveString(state, for: KeychainService.Key.whoopOAuthState)

        // Build authorization URL
        var components = URLComponents(string: Configuration.whoopAuthURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Configuration.whoopClientId),
            URLQueryItem(name: "redirect_uri", value: Configuration.whoopRedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Configuration.whoopScopes),
            URLQueryItem(name: "state", value: state)
        ]

        guard let authURL = components.url else {
            throw ReadyDayError.invalidURL
        }

        // Launch OAuth flow
        let callbackURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "readyday"
            ) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: ReadyDayError.authenticationFailed)
                    return
                }

                continuation.resume(returning: callbackURL)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false

            self.currentAuthSession = session
            session.start()
        }

        // Extract code and state from callback URL
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
              let returnedState = components.queryItems?.first(where: { $0.name == "state" })?.value else {
            throw ReadyDayError.authenticationFailed
        }

        // Verify state matches (CSRF protection)
        let storedState = try keychainService.loadString(for: KeychainService.Key.whoopOAuthState)
        guard returnedState == storedState else {
            throw ReadyDayError.authenticationFailed
        }

        // Exchange code for tokens
        let tokenResponse = try await exchangeCodeForTokens(code: code)

        // Clean up state
        try keychainService.delete(for: KeychainService.Key.whoopOAuthState)

        // Save tokens to Supabase (non-blocking)
        await saveTokensToSupabase(tokenResponse: tokenResponse)

        // Fetch Whoop profile and update user record
        await fetchAndSaveWhoopProfile()

        isAuthenticated = true
    }

    func isConnected() async -> Bool {
        // Check if we have a refresh token (which is long-lived)
        do {
            let refreshToken = try keychainService.loadString(for: KeychainService.Key.whoopRefreshToken)
            return refreshToken != nil
        } catch {
            return false
        }
    }

    func disconnect() async throws {
        // Delete all Whoop tokens from Keychain
        try keychainService.delete(for: KeychainService.Key.whoopAccessToken)
        try keychainService.delete(for: KeychainService.Key.whoopRefreshToken)
        try keychainService.delete(for: KeychainService.Key.whoopTokenExpiry)

        isAuthenticated = false
    }

    // MARK: - Private Methods

    @discardableResult
    private func exchangeCodeForTokens(code: String) async throws -> WhoopTokenResponse {
        var request = URLRequest(url: URL(string: Configuration.whoopTokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // Build form-encoded body
        let bodyParams = [
            "grant_type": "authorization_code",
            "code": code,
            "client_id": Configuration.whoopClientId,
            "client_secret": Configuration.whoopClientSecret,
            "redirect_uri": Configuration.whoopRedirectURI
        ]

        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReadyDayError.networkError
        }

        guard httpResponse.statusCode == 200 else {
            throw ReadyDayError.authenticationFailed
        }

        let tokenResponse = try JSONDecoder().decode(WhoopTokenResponse.self, from: data)

        // Store tokens in Keychain
        try keychainService.saveString(tokenResponse.accessToken, for: KeychainService.Key.whoopAccessToken)
        try keychainService.saveString(tokenResponse.refreshToken, for: KeychainService.Key.whoopRefreshToken)

        // Calculate and store expiry date
        let expiryDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        try keychainService.saveDate(expiryDate, for: KeychainService.Key.whoopTokenExpiry)

        return tokenResponse
    }

    private func saveTokensToSupabase(tokenResponse: WhoopTokenResponse) async {
        do {
            guard let session = try? await supabaseManager.client.auth.session else { return }

            // Get user ID from users table
            let usersResponse = try await supabaseManager.client
                .from("users")
                .select("id")
                .eq("supabase_auth_id", value: session.user.id.uuidString)
                .limit(1)
                .execute()

            struct UserIdRow: Codable { let id: UUID }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let users = try decoder.decode([UserIdRow].self, from: usersResponse.data)
            guard let userId = users.first?.id else { return }

            let expiryDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
            let tokenRow = WhoopTokenRow(
                id: UUID(),
                userId: userId,
                accessToken: tokenResponse.accessToken,
                refreshToken: tokenResponse.refreshToken,
                tokenExpiresAt: expiryDate,
                scopes: tokenResponse.scope
            )

            try await supabaseManager.client
                .from("whoop_tokens")
                .upsert(tokenRow, onConflict: "user_id")
                .execute()

            print("[WhoopOAuth] Tokens saved to Supabase")
        } catch {
            print("[WhoopOAuth] Failed to save tokens to Supabase: \(error.localizedDescription)")
        }
    }

    private func fetchAndSaveWhoopProfile() async {
        do {
            let accessToken = try keychainService.loadString(for: KeychainService.Key.whoopAccessToken)
            guard let token = accessToken else { return }

            // Fetch Whoop profile
            var request = URLRequest(url: URL(string: "\(Configuration.whoopAPIBaseURL)/v1/user/profile/basic")!)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }

            struct WhoopProfile: Codable {
                let userId: Int
                let firstName: String?
                let lastName: String?

                enum CodingKeys: String, CodingKey {
                    case userId = "user_id"
                    case firstName = "first_name"
                    case lastName = "last_name"
                }
            }

            let profile = try JSONDecoder().decode(WhoopProfile.self, from: data)

            // Update users table with whoop_user_id
            guard let session = try? await supabaseManager.client.auth.session else { return }

            try await supabaseManager.client
                .from("users")
                .update(["whoop_user_id": profile.userId])
                .eq("supabase_auth_id", value: session.user.id.uuidString)
                .execute()

            print("[WhoopOAuth] Whoop profile saved: user_id=\(profile.userId)")
        } catch {
            print("[WhoopOAuth] Failed to fetch Whoop profile: \(error.localizedDescription)")
        }
    }

    private func refreshToken() async throws {
        guard let refreshToken = try keychainService.loadString(for: KeychainService.Key.whoopRefreshToken) else {
            throw ReadyDayError.whoopTokenExpired
        }

        var request = URLRequest(url: URL(string: Configuration.whoopTokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParams = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": Configuration.whoopClientId,
            "client_secret": Configuration.whoopClientSecret
        ]

        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReadyDayError.networkError
        }

        guard httpResponse.statusCode == 200 else {
            // Refresh token is invalid, clear all tokens
            try? await disconnect()
            throw ReadyDayError.whoopTokenExpired
        }

        let tokenResponse = try JSONDecoder().decode(WhoopTokenResponse.self, from: data)

        // Update tokens in Keychain
        try keychainService.saveString(tokenResponse.accessToken, for: KeychainService.Key.whoopAccessToken)
        try keychainService.saveString(tokenResponse.refreshToken, for: KeychainService.Key.whoopRefreshToken)

        let expiryDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        try keychainService.saveDate(expiryDate, for: KeychainService.Key.whoopTokenExpiry)
    }

    private func generateRandomState() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<16).map { _ in letters.randomElement()! })
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension WhoopOAuthManager: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(iOS)
        // Get the key window from connected scenes
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first { $0.isKeyWindow } ?? windowScene?.windows.first ?? UIWindow()
        #else
        return NSApplication.shared.windows.first ?? NSWindow()
        #endif
    }
}
