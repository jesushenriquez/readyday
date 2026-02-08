import Foundation

enum ReadyDayError: LocalizedError, Sendable {

    // Auth
    case appleSignInFailed
    case whoopOAuthFailed(underlying: String)
    case whoopTokenExpired
    case whoopTokenRefreshFailed

    // Data
    case whoopDataUnavailable
    case calendarAccessDenied
    case calendarAccessRestricted
    case noRecoveryData
    case noSleepData

    // Network
    case networkUnavailable
    case serverError(statusCode: Int)
    case rateLimited(retryAfter: TimeInterval)
    case decodingError(underlying: String)

    // General
    case unknown(underlying: String)

    var errorDescription: String? {
        switch self {
        case .appleSignInFailed:
            "Apple Sign In failed. Please try again."
        case .whoopOAuthFailed(let detail):
            "Whoop connection failed: \(detail)"
        case .whoopTokenExpired:
            "Your Whoop session has expired. Please reconnect."
        case .whoopTokenRefreshFailed:
            "Could not refresh Whoop connection. Please reconnect."
        case .whoopDataUnavailable:
            "Whoop data is currently unavailable."
        case .calendarAccessDenied:
            "Calendar access was denied. Enable it in Settings."
        case .calendarAccessRestricted:
            "Calendar access is restricted on this device."
        case .noRecoveryData:
            "No recovery data available yet."
        case .noSleepData:
            "No sleep data available yet."
        case .networkUnavailable:
            "No internet connection. Showing cached data."
        case .serverError(let code):
            "Server error (\(code)). Please try again later."
        case .rateLimited(let retryAfter):
            "Too many requests. Please wait \(Int(retryAfter)) seconds."
        case .decodingError(let detail):
            "Data format error: \(detail)"
        case .unknown(let detail):
            "Something went wrong: \(detail)"
        }
    }
}
