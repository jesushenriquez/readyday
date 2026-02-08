import Foundation

protocol KeychainServiceProtocol: Sendable {
    func save(_ data: Data, for key: String) throws
    func load(for key: String) throws -> Data?
    func delete(for key: String) throws
}

final class KeychainService: KeychainServiceProtocol, Sendable {

    enum Key {
        static let whoopAccessToken = "com.readyday.whoop.accessToken"
        static let whoopRefreshToken = "com.readyday.whoop.refreshToken"
        static let whoopTokenExpiry = "com.readyday.whoop.tokenExpiry"
    }

    func save(_ data: Data, for key: String) throws {
        // TODO: Implement Keychain save in Sprint 1
    }

    func load(for key: String) throws -> Data? {
        // TODO: Implement Keychain load in Sprint 1
        nil
    }

    func delete(for key: String) throws {
        // TODO: Implement Keychain delete in Sprint 1
    }
}
