import XCTest
@testable import ReadyDay

final class WhoopAPIClientTests: XCTestCase {
    var sut: WhoopAPIClient!
    var mockOAuthManager: MockWhoopOAuthManager!

    override func setUp() {
        super.setUp()
        mockOAuthManager = MockWhoopOAuthManager()
        sut = WhoopAPIClient(oauthManager: mockOAuthManager)
    }

    override func tearDown() {
        sut = nil
        mockOAuthManager = nil
        super.tearDown()
    }

    // MARK: - Recovery DTO Decoding Tests

    func testDecodeRecoveryDTO() throws {
        // Given
        let json = """
        {
            "cycle_id": 123456,
            "sleep_id": "550e8400-e29b-41d4-a716-446655440000",
            "score_state": "SCORED",
            "created_at": "2024-01-15T08:30:00.000Z",
            "score": {
                "recovery_score": 75,
                "resting_heart_rate": 52,
                "hrv_rmssd_milli": 65.5,
                "spo2_percentage": 97.2,
                "skin_temp_celsius": 33.8,
                "user_calibrating": false
            }
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(RecoveryDTO.self, from: json)

        // Then
        XCTAssertEqual(dto.cycleId, 123456)
        XCTAssertEqual(dto.sleepId, "550e8400-e29b-41d4-a716-446655440000")
        XCTAssertEqual(dto.scoreState, "SCORED")
        XCTAssertEqual(dto.score?.recoveryScore, 75)
        XCTAssertEqual(dto.score?.restingHeartRate, 52)
        XCTAssertEqual(dto.score?.hrvRmssdMilli, 65.5)
        XCTAssertEqual(dto.score?.spo2Percentage, 97.2)
        XCTAssertEqual(dto.score?.skinTempCelsius, 33.8)
        XCTAssertEqual(dto.score?.userCalibrating, false)
    }

    func testDecodeRecoveryDTOWithPendingScore() throws {
        // Given - No score data yet
        let json = """
        {
            "cycle_id": 123456,
            "sleep_id": "550e8400-e29b-41d4-a716-446655440000",
            "score_state": "PENDING",
            "created_at": "2024-01-15T08:30:00.000Z"
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(RecoveryDTO.self, from: json)

        // Then
        XCTAssertEqual(dto.scoreState, "PENDING")
        XCTAssertNil(dto.score)
    }

    // MARK: - Sleep DTO Decoding Tests

    func testDecodeSleepDTO() throws {
        // Given
        let json = """
        {
            "id": "123456789",
            "start": "2024-01-14T23:00:00.000Z",
            "end": "2024-01-15T07:30:00.000Z",
            "nap": false,
            "score_state": "SCORED",
            "score": {
                "stage_summary": {
                    "total_in_bed_time_milli": 30600000,
                    "total_awake_time_milli": 1800000,
                    "total_light_sleep_time_milli": 14400000,
                    "total_slow_wave_sleep_time_milli": 7200000,
                    "total_rem_sleep_time_milli": 7200000
                },
                "sleep_needed": {
                    "baseline_milli": 28800000,
                    "need_from_sleep_debt_milli": 1800000,
                    "need_from_recent_strain_milli": 0,
                    "need_from_recent_nap_milli": 0
                },
                "sleep_efficiency": 94.1,
                "sleep_consistency": 85,
                "respiratory_rate": 15.5
            }
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(SleepDTO.self, from: json)

        // Then
        XCTAssertEqual(dto.id, "123456789")
        XCTAssertEqual(dto.nap, false)
        XCTAssertEqual(dto.scoreState, "SCORED")
        XCTAssertEqual(dto.score?.stageSummary?.totalInBedTimeMilli, 30600000)
        XCTAssertEqual(dto.score?.stageSummary?.totalLightSleepTimeMilli, 14400000)
        XCTAssertEqual(dto.score?.stageSummary?.totalSlowWaveSleepTimeMilli, 7200000)
        XCTAssertEqual(dto.score?.stageSummary?.totalRemSleepTimeMilli, 7200000)
        XCTAssertEqual(dto.score?.sleepEfficiency, 94.1)
        XCTAssertEqual(dto.score?.sleepConsistency, 85)
        XCTAssertEqual(dto.score?.respiratoryRate, 15.5)
    }

    // MARK: - Workout DTO Decoding Tests

    func testDecodeWorkoutDTO() throws {
        // Given
        let json = """
        {
            "id": "987654321",
            "sport_id": 63,
            "start": "2024-01-15T17:00:00.000Z",
            "end": "2024-01-15T18:00:00.000Z",
            "score_state": "SCORED",
            "score": {
                "strain": 14.5,
                "average_heart_rate": 145,
                "max_heart_rate": 178,
                "kilojoule": 1250.5,
                "distance_meter": 5000.0,
                "zone_duration": {
                    "zone_zero_milli": 60000,
                    "zone_one_milli": 300000,
                    "zone_two_milli": 1200000,
                    "zone_three_milli": 1800000,
                    "zone_four_milli": 240000,
                    "zone_five_milli": 0
                }
            }
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(WorkoutDTO.self, from: json)

        // Then
        XCTAssertEqual(dto.id, "987654321")
        XCTAssertEqual(dto.sportId, 63)
        XCTAssertEqual(dto.scoreState, "SCORED")
        XCTAssertEqual(dto.score?.strain, 14.5)
        XCTAssertEqual(dto.score?.averageHeartRate, 145)
        XCTAssertEqual(dto.score?.maxHeartRate, 178)
        XCTAssertEqual(dto.score?.kilojoule, 1250.5)
        XCTAssertEqual(dto.score?.distanceMeter, 5000.0)
        XCTAssertEqual(dto.score?.zoneDuration?.zoneThreeMilli, 1800000)
    }

    // MARK: - Paginated Response Tests

    func testDecodePaginatedResponse() throws {
        // Given
        let json = """
        {
            "records": [
                {
                    "cycle_id": 123,
                    "score_state": "SCORED",
                    "created_at": "2024-01-15T08:30:00.000Z",
                    "score": {
                        "recovery_score": 75,
                        "resting_heart_rate": 52,
                        "hrv_rmssd_milli": 65.5,
                        "spo2_percentage": 97.2,
                        "skin_temp_celsius": 33.8,
                        "user_calibrating": false
                    }
                }
            ],
            "next_token": "next_page_token_123"
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(WhoopPaginatedResponse<RecoveryDTO>.self, from: json)

        // Then
        XCTAssertEqual(response.records.count, 1)
        XCTAssertEqual(response.nextToken, "next_page_token_123")
        XCTAssertEqual(response.records.first?.cycleId, 123)
    }

    func testDecodePaginatedResponseWithoutNextToken() throws {
        // Given - Last page has no next token
        let json = """
        {
            "records": [
                {
                    "cycle_id": 456,
                    "score_state": "SCORED",
                    "created_at": "2024-01-15T08:30:00.000Z",
                    "score": {
                        "recovery_score": 82,
                        "resting_heart_rate": 48,
                        "hrv_rmssd_milli": 72.3,
                        "spo2_percentage": 98.1,
                        "skin_temp_celsius": 34.2,
                        "user_calibrating": false
                    }
                }
            ]
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(WhoopPaginatedResponse<RecoveryDTO>.self, from: json)

        // Then
        XCTAssertEqual(response.records.count, 1)
        XCTAssertNil(response.nextToken)
    }

    // MARK: - Date Parsing Tests

    func testDecodeDateInISO8601Format() throws {
        // Given
        let json = """
        {
            "cycle_id": 123,
            "score_state": "SCORED",
            "created_at": "2024-01-15T08:30:45.123Z",
            "score": {
                "recovery_score": 75,
                "resting_heart_rate": 52,
                "hrv_rmssd_milli": 65.5,
                "spo2_percentage": 97.2,
                "skin_temp_celsius": 33.8,
                "user_calibrating": false
            }
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let dto = try decoder.decode(RecoveryDTO.self, from: json)

        // Then
        XCTAssertNotNil(dto.createdAt)
        // Verify it's a valid ISO8601 string
        XCTAssertTrue(dto.createdAt.contains("2024-01-15"))
    }
}

// MARK: - Mock WhoopOAuthManager

@MainActor
final class MockWhoopOAuthManager: WhoopOAuthManagerProtocol {
    var isAuthenticated = false
    var mockToken = "mock_access_token"
    var shouldThrowError = false

    func startOAuthFlow() async throws {
        if shouldThrowError {
            throw ReadyDayError.whoopOAuthFailed
        }
        isAuthenticated = true
    }

    func getValidToken() async throws -> String {
        if shouldThrowError {
            throw ReadyDayError.whoopTokenExpired
        }
        return mockToken
    }

    func isConnected() async -> Bool {
        return isAuthenticated
    }

    func disconnect() async throws {
        if shouldThrowError {
            throw ReadyDayError.keychainError
        }
        isAuthenticated = false
    }
}
