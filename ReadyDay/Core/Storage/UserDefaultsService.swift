import Foundation

protocol UserDefaultsServiceProtocol: Sendable {
    func bool(for key: String) -> Bool
    func set(_ value: Bool, for key: String)
    func string(for key: String) -> String?
    func set(_ value: String?, for key: String)
    func date(for key: String) -> Date?
    func set(_ value: Date?, for key: String)
}

final class UserDefaultsService: UserDefaultsServiceProtocol, @unchecked Sendable {
    private let defaults: UserDefaults

    enum Key {
        static let onboardingCompleted = "onboardingCompleted"
        static let lastSyncTimestamp = "lastSyncTimestamp"
        static let morningBriefingEnabled = "morningBriefingEnabled"
        static let selectedCalendarIds = "selectedCalendarIds"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func bool(for key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func set(_ value: Bool, for key: String) {
        defaults.set(value, forKey: key)
    }

    func string(for key: String) -> String? {
        defaults.string(forKey: key)
    }

    func set(_ value: String?, for key: String) {
        defaults.set(value, forKey: key)
    }

    func date(for key: String) -> Date? {
        defaults.object(forKey: key) as? Date
    }

    func set(_ value: Date?, for key: String) {
        defaults.set(value, forKey: key)
    }
}
