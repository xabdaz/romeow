import Foundation

public struct FormField: Equatable, Codable, Identifiable, Sendable {
    public let id: UUID
    public var key: String
    public var value: String

    public init(id: UUID = UUID(), key: String = "", value: String = "") {
        self.id = id
        self.key = key
        self.value = value
    }
}

public enum BodyContent: Equatable, Codable, Sendable {
    case none
    case json(String)
    case formUrlEncoded([FormField])
    case raw(String, contentType: String)

    public var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case .json(let string):
            return string.isEmpty
        case .formUrlEncoded(let fields):
            return fields.isEmpty || fields.allSatisfy { $0.key.isEmpty && $0.value.isEmpty }
        case .raw(let string, _):
            return string.isEmpty
        }
    }

    public var rawString: String? {
        switch self {
        case .none:
            return nil
        case .json(let string):
            return string
        case .formUrlEncoded(let fields):
            let encodedPairs = fields.compactMap { field -> String? in
                guard !field.key.isEmpty else { return nil }
                let encodedKey = field.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? field.key
                let encodedValue = field.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? field.value
                return "\(encodedKey)=\(encodedValue)"
            }
            return encodedPairs.joined(separator: "&")
        case .raw(let string, _):
            return string
        }
    }

    public var contentTypeOverride: String? {
        switch self {
        case .none:
            return nil
        case .json:
            return nil
        case .formUrlEncoded:
            return nil
        case .raw(_, let contentType):
            return contentType
        }
    }
}
