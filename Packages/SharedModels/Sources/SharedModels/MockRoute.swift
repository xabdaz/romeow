import Foundation

public struct MockRoute: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var workspaceId: UUID?     // NEW: untuk grouping by workspace
    public var name: String           // NEW: display name untuk UI
    public var method: HTTPMethod
    public var path: String
    public var statusCode: Int
    public var responseHeaders: [String: String]
    public var responseBody: String
    public var isEnabled: Bool
    public var createdAt: Date        // NEW
    public var updatedAt: Date        // NEW

    public init(
        id: UUID = UUID(),
        workspaceId: UUID? = nil,
        name: String = "",
        method: HTTPMethod = .get,
        path: String = "/",
        statusCode: Int = 200,
        responseHeaders: [String: String] = ["Content-Type": "application/json"],
        responseBody: String = "{}",
        isEnabled: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.name = name
        self.method = method
        self.path = path
        self.statusCode = statusCode
        self.responseHeaders = responseHeaders
        self.responseBody = responseBody
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
