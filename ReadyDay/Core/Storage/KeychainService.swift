import Foundation
import Security

protocol KeychainServiceProtocol: Sendable {
    func save(_ data: Data, for key: String) throws
    func load(for key: String) throws -> Data?
    func delete(for key: String) throws
}

enum KeychainError: Error, Sendable {
    case unexpectedError(status: OSStatus)
    case itemNotFound
    case invalidData
}

final class KeychainService: KeychainServiceProtocol, Sendable {

    enum Key {
        static let whoopAccessToken = "com.readyday.whoop.accessToken"
        static let whoopRefreshToken = "com.readyday.whoop.refreshToken"
        static let whoopTokenExpiry = "com.readyday.whoop.tokenExpiry"
        static let whoopOAuthState = "com.readyday.whoop.oauthState"
    }

    // MARK: - Core Data Methods

    func save(_ data: Data, for key: String) throws {
        // First, try to update existing item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.readyday.app"
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        var status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        // If item doesn't exist, add it
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

            status = SecItemAdd(addQuery as CFDictionary, nil)
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedError(status: status)
        }
    }

    func load(for key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.readyday.app",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedError(status: status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return data
    }

    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.readyday.app"
        ]

        let status = SecItemDelete(query as CFDictionary)

        // Deleting a non-existent item is not an error
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedError(status: status)
        }
    }

    // MARK: - Convenience Methods

    func saveString(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        try save(data, for: key)
    }

    func loadString(for key: String) throws -> String? {
        guard let data = try load(for: key) else {
            return nil
        }

        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return string
    }

    func saveDate(_ date: Date, for key: String) throws {
        let timestamp = date.timeIntervalSince1970
        let string = String(timestamp)
        try saveString(string, for: key)
    }

    func loadDate(for key: String) throws -> Date? {
        guard let string = try loadString(for: key) else {
            return nil
        }

        guard let timestamp = TimeInterval(string) else {
            throw KeychainError.invalidData
        }

        return Date(timeIntervalSince1970: timestamp)
    }
}
