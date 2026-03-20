import Foundation

public enum BodyType: String, Equatable, Codable, CaseIterable, Sendable {
    case none = "none"
    case json = "json"
    case formUrlEncoded = "formUrlEncoded"
    case raw = "raw"

    public var displayName: String {
        switch self {
        case .none:
            return "None"
        case .json:
            return "JSON"
        case .formUrlEncoded:
            return "Form URL-Encoded"
        case .raw:
            return "Raw"
        }
    }

    public var defaultContentType: String {
        switch self {
        case .none:
            return ""
        case .json:
            return "application/json"
        case .formUrlEncoded:
            return "application/x-www-form-urlencoded"
        case .raw:
            return "text/plain"
        }
    }
}
