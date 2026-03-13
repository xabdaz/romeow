import Foundation
import Dependencies
import SharedModels

// MARK: - Client

public struct MockServerClient: Sendable {
    public var start: @Sendable (_ port: Int, _ routes: [MockRoute]) async throws -> Void
    public var stop: @Sendable () async throws -> Void
    public var isRunning: @Sendable () -> Bool

    public init(
        start: @Sendable @escaping (_ port: Int, _ routes: [MockRoute]) async throws -> Void,
        stop: @Sendable @escaping () async throws -> Void,
        isRunning: @Sendable @escaping () -> Bool
    ) {
        self.start = start
        self.stop = stop
        self.isRunning = isRunning
    }
}

// MARK: - Dependency

extension MockServerClient: DependencyKey {
    public static let liveValue = MockServerClient(
        start: { port, routes in
            // Implementasi Hummingbird v2 di sini
            // HBApplication akan di-setup dengan routes yang diberikan
        },
        stop: {
            // Stop HBApplication
        },
        isRunning: {
            false // Track state dari HBApplication
        }
    )

    public static let testValue = MockServerClient(
        start: { _, _ in },
        stop: { },
        isRunning: { false }
    )
}

extension DependencyValues {
    public var mockServerClient: MockServerClient {
        get { self[MockServerClient.self] }
        set { self[MockServerClient.self] = newValue }
    }
}
