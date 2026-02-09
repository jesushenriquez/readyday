import Foundation
import AuthenticationServices
import Supabase

protocol AuthManagerProtocol: Sendable {
    func signInWithApple() async throws
    func getCurrentSession() async -> Session?
    func signOut() async throws
    var isAuthenticated: Bool { get async }
}

@Observable
@MainActor
final class AuthManager: NSObject, AuthManagerProtocol, @unchecked Sendable {

    private(set) var isAuthenticated = false
    private let supabaseManager: SupabaseManager
    private let whoopOAuthManager: WhoopOAuthManager

    private var authContinuation: CheckedContinuation<ASAuthorization, Error>?

    init(supabaseManager: SupabaseManager, whoopOAuthManager: WhoopOAuthManager) {
        self.supabaseManager = supabaseManager
        self.whoopOAuthManager = whoopOAuthManager
        super.init()

        // Check initial auth state
        Task {
            if let _ = try? await supabaseManager.client.auth.session {
                self.isAuthenticated = true
            }
        }
    }

    // MARK: - Public Methods

    func signInWithApple() async throws {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self

        // Launch sign in flow
        let authorization = try await withCheckedThrowingContinuation { continuation in
            self.authContinuation = continuation
            authController.performRequests()
        }

        // Extract credential
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw ReadyDayError.appleSignInFailed
        }

        // Sign in to Supabase with Apple ID token
        try await supabaseManager.client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: tokenString
            )
        )

        // Get the session to extract user ID
        let session = try await supabaseManager.client.auth.session

        // Create user record if first time (non-blocking — auth is already successful)
        let userRow = UserRow(
            id: UUID(),
            supabaseAuthId: session.user.id,
            whoopUserId: nil,
            email: appleIDCredential.email ?? session.user.email,
            displayName: [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
                .nilIfEmpty(),
            timezone: TimeZone.current.identifier,
            onboardingCompleted: false
        )

        do {
            try await supabaseManager.client
                .from("users")
                .upsert(userRow, onConflict: "supabase_auth_id", ignoreDuplicates: true)
                .execute()
        } catch {
            // User already exists — this is fine
            print("[AuthManager] User record note: \(error.localizedDescription)")
        }

        isAuthenticated = true
    }

    func getCurrentSession() async -> Session? {
        try? await supabaseManager.client.auth.session
    }

    func signOut() async throws {
        // Sign out from Supabase
        try await supabaseManager.client.auth.signOut()

        // Disconnect Whoop
        try await whoopOAuthManager.disconnect()

        isAuthenticated = false
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthManager: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            authContinuation?.resume(returning: authorization)
            authContinuation = nil
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            authContinuation?.resume(throwing: error)
            authContinuation = nil
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(iOS)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first { $0.isKeyWindow } ?? windowScene?.windows.first ?? UIWindow()
        #else
        return NSApplication.shared.windows.first ?? NSWindow()
        #endif
    }
}

// MARK: - String Extension

private extension String {
    func nilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
}
