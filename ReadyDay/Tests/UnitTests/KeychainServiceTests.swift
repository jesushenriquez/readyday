import XCTest
@testable import ReadyDay

final class KeychainServiceTests: XCTestCase {
    var sut: KeychainService!
    let testKey = "com.readyday.test.key"

    override func setUp() {
        super.setUp()
        sut = KeychainService()
        // Clean up any existing test data
        try? sut.delete(for: testKey)
    }

    override func tearDown() {
        // Clean up after tests
        try? sut.delete(for: testKey)
        sut = nil
        super.tearDown()
    }

    // MARK: - Data Tests

    func testSaveAndLoadData() throws {
        // Given
        let testData = "Hello Keychain".data(using: .utf8)!

        // When
        try sut.save(testData, for: testKey)
        let loadedData = try sut.load(for: testKey)

        // Then
        XCTAssertEqual(testData, loadedData)
    }

    func testUpdateExistingData() throws {
        // Given
        let originalData = "Original".data(using: .utf8)!
        let updatedData = "Updated".data(using: .utf8)!

        // When
        try sut.save(originalData, for: testKey)
        try sut.save(updatedData, for: testKey) // Should update, not fail
        let loadedData = try sut.load(for: testKey)

        // Then
        XCTAssertEqual(updatedData, loadedData)
    }

    func testDeleteData() throws {
        // Given
        let testData = "Delete me".data(using: .utf8)!
        try sut.save(testData, for: testKey)

        // When
        try sut.delete(for: testKey)
        let loadedData = try? sut.load(for: testKey)

        // Then
        XCTAssertNil(loadedData)
    }

    func testLoadNonExistentData() throws {
        // When
        let loadedData = try? sut.load(for: "nonexistent.key")

        // Then
        XCTAssertNil(loadedData)
    }

    // MARK: - String Tests

    func testSaveAndLoadString() throws {
        // Given
        let testString = "Test String"

        // When
        try sut.saveString(testString, for: testKey)
        let loadedString = try sut.loadString(for: testKey)

        // Then
        XCTAssertEqual(testString, loadedString)
    }

    func testLoadNonExistentString() throws {
        // When
        let loadedString = try? sut.loadString(for: "nonexistent.string")

        // Then
        XCTAssertNil(loadedString)
    }

    // MARK: - Date Tests

    func testSaveAndLoadDate() throws {
        // Given
        let testDate = Date()

        // When
        try sut.saveDate(testDate, for: testKey)
        let loadedDate = try sut.loadDate(for: testKey)

        // Then
        XCTAssertNotNil(loadedDate)
        // Compare timestamps within 1 second tolerance (encoding may lose milliseconds)
        XCTAssertEqual(testDate.timeIntervalSince1970, loadedDate?.timeIntervalSince1970 ?? 0, accuracy: 1.0)
    }

    func testLoadNonExistentDate() throws {
        // When
        let loadedDate = try? sut.loadDate(for: "nonexistent.date")

        // Then
        XCTAssertNil(loadedDate)
    }

    // MARK: - Full Cycle Test

    func testFullSaveLoadDeleteCycle() throws {
        // Given
        let testData = "Cycle Test".data(using: .utf8)!

        // When - Save
        try sut.save(testData, for: testKey)
        let savedData = try sut.load(for: testKey)
        XCTAssertEqual(testData, savedData)

        // When - Update
        let updatedData = "Updated Cycle".data(using: .utf8)!
        try sut.save(updatedData, for: testKey)
        let loadedUpdatedData = try sut.load(for: testKey)
        XCTAssertEqual(updatedData, loadedUpdatedData)

        // When - Delete
        try sut.delete(for: testKey)
        let deletedData = try? sut.load(for: testKey)
        XCTAssertNil(deletedData)
    }
}
