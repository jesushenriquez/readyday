import Foundation

enum Configuration {

    // MARK: - Supabase

    static var supabaseURL: String {
        stringValue(for: "SUPABASE_URL")
    }

    static var supabaseAnonKey: String {
        stringValue(for: "SUPABASE_ANON_KEY")
    }

    // MARK: - Whoop

    static var whoopClientId: String {
        stringValue(for: "WHOOP_CLIENT_ID")
    }

    static var whoopClientSecret: String {
        stringValue(for: "WHOOP_CLIENT_SECRET")
    }

    static var whoopRedirectURI: String {
        stringValue(for: "WHOOP_REDIRECT_URI")
    }

    static let whoopAuthURL = "https://api.prod.whoop.com/oauth/oauth2/auth"
    static let whoopTokenURL = "https://api.prod.whoop.com/oauth/oauth2/token"
    static let whoopAPIBaseURL = "https://api.prod.whoop.com/developer"
    static let whoopScopes = "read:recovery read:sleep read:workout read:cycles read:profile read:body_measurement offline"

    // MARK: - PostHog

    static var posthogAPIKey: String {
        stringValue(for: "POSTHOG_API_KEY")
    }

    static var posthogHost: String {
        stringValue(for: "POSTHOG_HOST")
    }

    // MARK: - Environment

    static var environment: String {
        stringValue(for: "ENVIRONMENT")
    }

    static var isDevelopment: Bool {
        environment == "development"
    }

    // MARK: - Helpers

    private static func stringValue(for key: String) -> String {
        Bundle.main.infoDictionary?[key] as? String ?? ""
    }
}
