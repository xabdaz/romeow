import Foundation

public struct MockRoute: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var method: HTTPMethod
    public var path: String
    public var statusCode: Int
    public var responseHeaders: [String: String]
    public var responseBody: String
    public var isEnabled: Bool

    public init(
        id: UUID = UUID(),
        method: HTTPMethod = .get,
        path: String = "/",
        statusCode: Int = 200,
        responseHeaders: [String: String] = ["Content-Type": "application/json"],
        responseBody: String = "{}",
        isEnabled: Bool = true
    ) {
        self.id = id
        self.method = method
        self.path = path
        self.statusCode = statusCode
        self.responseHeaders = responseHeaders
        self.responseBody = responseBody
        self.isEnabled = isEnabled
    }
}
