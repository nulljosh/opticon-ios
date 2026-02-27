import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case httpError(Int, String)
    case decodingError(String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .httpError(let code, let message):
            return "HTTP \(code): \(message)"
        case .decodingError(let detail):
            return "Decode error: \(detail)"
        case .unauthorized:
            return "Not authenticated"
        }
    }
}

@MainActor
final class OpticonAPI: @unchecked Sendable {
    static let shared = OpticonAPI()

    private let baseURL = "https://opticon.heyitsmejosh.com"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        session = URLSession(configuration: config)
    }

    // MARK: - Auth

    func login(email: String, password: String) async throws -> User {
        let url = try makeURL("/api/auth", query: ["action": "login"])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        let data = try await perform(request)
        return try decode(User.self, from: data)
    }

    func logout() async throws {
        let url = try makeURL("/api/auth", query: ["action": "logout"])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        _ = try await perform(request)
    }

    func me() async throws -> User {
        let url = try makeURL("/api/auth", query: ["action": "me"])
        let request = URLRequest(url: url)
        let data = try await perform(request)
        return try decode(User.self, from: data)
    }

    // MARK: - Market Data

    func fetchStocks() async throws -> [Stock] {
        let url = try makeURL("/api/stocks")
        let request = URLRequest(url: url)
        let data = try await perform(request)
        return try decode([Stock].self, from: data)
    }

    // MARK: - Portfolio

    func fetchPortfolio() async throws -> Portfolio {
        let url = try makeURL("/api/portfolio", query: ["action": "get"])
        let request = URLRequest(url: url)
        let data = try await perform(request)
        return try decode(Portfolio.self, from: data)
    }

    // MARK: - Internals

    private func makeURL(_ path: String, query: [String: String] = [:]) throws -> URL {
        var components = URLComponents(string: baseURL + path)
        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components?.url else { throw APIError.invalidURL }
        return url
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.httpError(0, "No HTTP response")
        }
        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 401 { throw APIError.unauthorized }
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw APIError.httpError(http.statusCode, body)
        }
        return data
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}
