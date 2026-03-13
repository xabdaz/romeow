import Foundation

public struct APIResponse: Equatable, Sendable {
    public var statusCode: Int
    public var headers: [String: String]
    public var body: Data?
    public var duration: TimeInterval

    public init(
        statusCode: Int,
        headers: [String: String] = [:],
        body: Data? = nil,
        duration: TimeInterval = 0
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.duration = duration
    }

    public var isSuccess: Bool { (200..<300).contains(statusCode) }

    public var bodyString: String? {
        guard let body else { return nil }
        return String(data: body, encoding: .utf8)
    }
}
