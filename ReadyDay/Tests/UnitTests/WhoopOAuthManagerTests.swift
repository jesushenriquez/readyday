import XCTest
@testable import ReadyDay

final class WhoopOAuthManagerTests: XCTestCase {
    var sut: WhoopOAuthManager!
    var mockKeychainService: MockKeychainService!

    override func setUp() {
        super.setUp()
        mockKeychainService = MockKeychainService()
        sut = WhoopOAuthManager(keychainService: mockKeychainService)
    }

    override func tearDown() {
        sut = nil
        mockKeychainService = nil
        super.tearDown()
    }

    // MARK: - State Generation Tests

    func testGenerateRandomStateCreatesValidString() {
        // When
        let state1 = sut.generateRandomState()
        let state2 = sut.generateRandomState()

        // Then
        XCTAssertEqual(state1.count, 16, "State should be 16 characters")
        XCTAssertNotEqual(state1, state2, "Each state should be unique")
        XCTAssertTrue(state1.allSatisfy { $0.isLetter || $0.isNumber }, "State should only contain alphanumeric characters")
    }

    // MARK: - Token Storage Tests

    func testIsConnectedReturnsFalseWhenNoToken() async {
        // Given - No tokens in keychain
        mockKeychainService.storedData.removeAll()

        // When
        let isConnected = await sut.isConnected()

        // Then
        XCTAssertFalse(isConnected)
    }

    func testIsConnectedReturnsTrueWithValidToken() async {
        // Given - Valid token stored
        mockKeychainService.storedData["whoop_access_token"] = "valid_token".data(using: .utf8)!
        let futureDate = Date().addingTimeInterval(3600)
        mockKeychainService.storedDates["whoop_token_expiry"] = futureDate

        // When
        let isConnected = await sut.isConnected()

        // Then
        XCTAssertTrue(isConnected)
    }

    func testIsConnectedReturnsFalseWithExpiredToken() async {
        // Given - Expired token
        mockKeychainService.storedData["whoop_access_token"] = "valid_token".data(using: .utf8)!
        let pastDate = Date().addingTimeInterval(-3600)
        mockKeychainService.storedDates["whoop_token_expiry"] = pastDate

        // When
        let isConnected = await sut.isConnected()

        // Then
        XCTAssertFalse(isConnected)
    }

    // MARK: - Disconnect Tests

    func testDisconnectRemovesAllTokens() async throws {
        // Given - Tokens stored
        mockKeychainService.storedData["whoop_access_token"] = "token".data(using: .utf8)!
        mockKeychainService.storedData["whoop_refresh_token"] = "refresh".data(using: .utf8)!
        mockKeychainService.storedDates["whoop_token_expiry"] = Date()

        // When
        try await sut.disconnect()

        // Then
        XCTAssertNil(mockKeychainService.storedData["whoop_access_token"])
        XCTAssertNil(mockKeychainService.storedData["whoop_refresh_token"])
        XCTAssertNil(mockKeychainService.storedDates["whoop_token_expiry"])
    }

    // MARK: - Token Validation Tests

    func testGetValidTokenReturnsStoredTokenWhenNotExpired() async throws {
        // Given - Valid token that won't expire for an hour
        let validToken = "valid_access_token"
        mockKeychainService.storedData["whoop_access_token"] = validToken.data(using: .utf8)!
        mockKeychainService.storedData["whoop_refresh_token"] = "refresh_token".data(using: .utf8)!
        let futureExpiry = Date().addingTimeInterval(3600) // 1 hour from now
        mockKeychainService.storedDates["whoop_token_expiry"] = futureExpiry

        // When
        let token = try await sut.getValidToken()

        // Then
        XCTAssertEqual(token, validToken)
    }

    func testGetValidTokenThrowsWhenNoTokenStored() async {
        // Given - No tokens
        mockKeychainService.storedData.removeAll()

        // When/Then
        do {
            _ = try await sut.getValidToken()
            XCTFail("Should throw error when no token stored")
        } catch {
            // Expected
            XCTAssertTrue(error is ReadyDayError)
        }
    }
}

// MARK: - Mock KeychainService

final class MockKeychainService: KeychainServiceProtocol, @unchecked Sendable {
    private var _storedData: [String: Data] = [:]
    private var _storedDates: [String: Date] = [:]
    private var _shouldThrowError = false

    var storedData: [String: Data] {
        get { _storedData }
        set { _storedData = newValue }
    }

    var storedDates: [String: Date] {
        get { _storedDates }
        set { _storedDates = newValue }
    }

    var shouldThrowError: Bool {
        get { _shouldThrowError }
        set { _shouldThrowError = newValue }
    }

    func save(_ data: Data, for key: String) throws {
        if shouldThrowError {
            throw ReadyDayError.keychainError
        }
        storedData[key] = data
    }

    func load(for key: String) throws -> Data? {
        if shouldThrowError {
            throw ReadyDayError.keychainError
        }
        return storedData[key]
    }

    func delete(for key: String) throws {
        if shouldThrowError {
            throw ReadyDayError.keychainError
        }
        storedData.removeValue(forKey: key)
        storedDates.removeValue(forKey: key)
    }

    func saveString(_ string: String, for key: String) throws {
        if shouldThrowError {
            throw ReadyDayError.keychainError
        }
        storedData[key] = string.data(using: .utf8)
    }

    func loadString(for key: String) throws -> String? {
        if shouldThrowError {
            throw ReadyDayError.keychainError
        }
        guard let data = storedData[key] else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func saveDate(_ date: Date, for key: String) throws {
        if shouldThrowError {
            throw ReadyDayError.keychainError
        }
        storedDates[key] = date
    }

    func loadDate(for key: String) throws -> Date? {
        if shouldThrowError {
            throw ReadyDayError.keychainError
        }
        return storedDates[key]
    }
}
