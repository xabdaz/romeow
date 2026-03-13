import Foundation

public struct APIRequest: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var method: HTTPMethod
    public var url: String
    public var headers: [String: String]
    public var body: String?

    public init(
        id: UUID = UUID(),
        name: String = "New Request",
        method: HTTPMethod = .get,
        url: String = "",
        headers: [String: String] = [:],
        body: String? = nil
    ) {
        self.id = id
        self.name = name
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
    }
}

public enum HTTPMethod: String, Equatable, Codable, CaseIterable, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
}
