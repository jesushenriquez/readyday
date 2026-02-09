import Foundation

protocol WhoopAPIClientProtocol: Sendable {
    func getCycles(start: Date?, end: Date?, limit: Int) async throws -> [WhoopCycleDTO]
    func getRecoveries(start: Date?, end: Date?, limit: Int) async throws -> [WhoopRecoveryDTO]
    func getSleeps(start: Date?, end: Date?, limit: Int) async throws -> [WhoopSleepDTO]
    func getWorkouts(start: Date?, end: Date?, limit: Int) async throws -> [WhoopWorkoutDTO]
    func getProfile() async throws -> WhoopProfileDTO
}

// MARK: - Paginated Response

struct WhoopPaginatedResponse<T: Codable>: Codable {
    let records: [T]
    let nextToken: String?

    enum CodingKeys: String, CodingKey {
        case records
        case nextToken = "next_token"
    }
}

// MARK: - Whoop API Client

final class WhoopAPIClient: WhoopAPIClientProtocol, Sendable {
    private let baseURL = Configuration.whoopAPIBaseURL
    private let oauthManager: WhoopOAuthManagerProtocol
    private let decoder: JSONDecoder

    init(oauthManager: WhoopOAuthManagerProtocol) {
        self.oauthManager = oauthManager

        // Configure decoder for snake_case
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Use iso8601 date decoding strategy
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Public Methods

    func getCycles(start: Date? = nil, end: Date? = nil, limit: Int = 25) async throws -> [WhoopCycleDTO] {
        var queryItems: [URLQueryItem] = []

        if let start = start {
            queryItems.append(URLQueryItem(name: "start", value: ISO8601DateFormatter().string(from: start)))
        }
        if let end = end {
            queryItems.append(URLQueryItem(name: "end", value: ISO8601DateFormatter().string(from: end)))
        }
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))

        let response: WhoopPaginatedResponse<WhoopCycleDTO> = try await request(
            endpoint: "/v1/cycle",
            queryItems: queryItems
        )

        return response.records
    }

    func getRecoveries(start: Date? = nil, end: Date? = nil, limit: Int = 25) async throws -> [WhoopRecoveryDTO] {
        var queryItems: [URLQueryItem] = []

        if let start = start {
            queryItems.append(URLQueryItem(name: "start", value: ISO8601DateFormatter().string(from: start)))
        }
        if let end = end {
            queryItems.append(URLQueryItem(name: "end", value: ISO8601DateFormatter().string(from: end)))
        }
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))

        let response: WhoopPaginatedResponse<WhoopRecoveryDTO> = try await request(
            endpoint: "/v1/recovery",
            queryItems: queryItems
        )

        return response.records
    }

    func getSleeps(start: Date? = nil, end: Date? = nil, limit: Int = 25) async throws -> [WhoopSleepDTO] {
        var queryItems: [URLQueryItem] = []

        if let start = start {
            queryItems.append(URLQueryItem(name: "start", value: ISO8601DateFormatter().string(from: start)))
        }
        if let end = end {
            queryItems.append(URLQueryItem(name: "end", value: ISO8601DateFormatter().string(from: end)))
        }
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))

        let response: WhoopPaginatedResponse<WhoopSleepDTO> = try await request(
            endpoint: "/v1/activity/sleep",
            queryItems: queryItems
        )

        return response.records
    }

    func getWorkouts(start: Date? = nil, end: Date? = nil, limit: Int = 25) async throws -> [WhoopWorkoutDTO] {
        var queryItems: [URLQueryItem] = []

        if let start = start {
            queryItems.append(URLQueryItem(name: "start", value: ISO8601DateFormatter().string(from: start)))
        }
        if let end = end {
            queryItems.append(URLQueryItem(name: "end", value: ISO8601DateFormatter().string(from: end)))
        }
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))

        let response: WhoopPaginatedResponse<WhoopWorkoutDTO> = try await request(
            endpoint: "/v1/activity/workout",
            queryItems: queryItems
        )

        return response.records
    }

    func getProfile() async throws -> WhoopProfileDTO {
        try await request(endpoint: "/v1/user/profile/basic", queryItems: [])
    }

    // MARK: - Private Methods

    private func request<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]
    ) async throws -> T {
        // Get valid access token
        let token = try await oauthManager.getValidToken()

        // Build URL
        guard var components = URLComponents(string: baseURL + endpoint) else {
            throw ReadyDayError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw ReadyDayError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Execute request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReadyDayError.networkError
        }

        // Handle HTTP status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode response
            do {
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                throw ReadyDayError.decodingError(underlying: error.localizedDescription)
            }

        case 401:
            // Unauthorized - token is invalid
            throw ReadyDayError.whoopTokenExpired

        case 429:
            // Rate limited
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                .flatMap { TimeInterval($0) } ?? 60
            throw ReadyDayError.rateLimited(retryAfter: retryAfter)

        case 500...599:
            // Server error
            throw ReadyDayError.serverError(statusCode: httpResponse.statusCode)

        default:
            throw ReadyDayError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
