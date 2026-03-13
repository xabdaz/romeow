import Foundation
import Dependencies
import SharedModels

// MARK: - Client

public struct URLSessionClient: Sendable {
    public var send: @Sendable (APIRequest) async throws -> APIResponse

    public init(send: @Sendable @escaping (APIRequest) async throws -> APIResponse) {
        self.send = send
    }
}

// MARK: - Dependency

extension URLSessionClient: DependencyKey {
    public static let liveValue = URLSessionClient { request in
        guard let url = URL(string: request.url) else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        request.headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        if let body = request.body {
            urlRequest.httpBody = body.data(using: .utf8)
        }

        let start = Date()
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        let duration = Date().timeIntervalSince(start)

        let httpResponse = response as! HTTPURLResponse
        let headers = httpResponse.allHeaderFields.reduce(into: [String: String]()) {
            $0["\($1.key)"] = "\($1.value)"
        }

        return APIResponse(
            statusCode: httpResponse.statusCode,
            headers: headers,
            body: data,
            duration: duration
        )
    }

    public static let testValue = URLSessionClient { _ in
        APIResponse(statusCode: 200, body: Data("{}".utf8))
    }
}

extension DependencyValues {
    public var urlSessionClient: URLSessionClient {
        get { self[URLSessionClient.self] }
        set { self[URLSessionClient.self] = newValue }
    }
}
