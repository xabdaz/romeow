import Foundation

// MARK: - Workspace
public struct Workspace: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var folders: [Folder]
    public var requests: [RequestItem]

    public init(
        id: UUID = UUID(),
        name: String,
        folders: [Folder] = [],
        requests: [RequestItem] = []
    ) {
        self.id = id
        self.name = name
        self.folders = folders
        self.requests = requests
    }
}

// MARK: - Folder
public struct Folder: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var requests: [RequestItem]

    public init(
        id: UUID = UUID(),
        name: String,
        requests: [RequestItem] = []
    ) {
        self.id = id
        self.name = name
        self.requests = requests
    }
}

// MARK: - RequestItem
public struct RequestItem: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var method: HTTPMethod
    public var url: String

    public init(
        id: UUID = UUID(),
        name: String,
        method: HTTPMethod = .get,
        url: String = ""
    ) {
        self.id = id
        self.name = name
        self.method = method
        self.url = url
    }
}

// MARK: - SidebarItem
public enum SidebarItem: Equatable, Hashable, Sendable {
    case request(UUID)
    case folder(UUID)
}
