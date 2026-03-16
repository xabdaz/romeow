import ComposableArchitecture
import HTTPTypes
import Hummingbird
import SharedModels

// MARK: - Server Manager

private actor ServerManager {
    private var serverTask: Task<Void, any Error>?

    // Reserved paths yang gak bisa di-override user
    private let reservedPaths = ["/health"]

    func start(port: Int, routes: [MockRoute]) {
        serverTask?.cancel()
        serverTask = Task {
            let router = Router()

            // Filter out reserved routes dari user routes
            let userRoutes = routes.filter { route in
                guard route.isEnabled else { return false }
                if reservedPaths.contains(route.path.lowercased()) {
                    print("[MockServer] Skipping reserved route: \(route.path)")
                    return false
                }
                return true
            }

            // Default health route (only if user doesn't override - tapi kita skip aja)
            router.get("/health") { _, _ -> String in
                #"{"status":"ok"}"#
            }

            // User-defined routes
            for route in userRoutes {
                guard let method = HTTPRequest.Method(route.method.rawValue) else { continue }
                let capturedRoute = route
                router.on(RouterPath(capturedRoute.path), method: method) { _, _ -> Response in
                    var headers = HTTPFields()
                    for (key, value) in capturedRoute.responseHeaders {
                        if let name = HTTPField.Name(key) {
                            headers.append(HTTPField(name: name, value: value))
                        }
                    }
                    return Response(
                        status: HTTPResponse.Status(code: capturedRoute.statusCode),
                        headers: headers,
                        body: ResponseBody(byteBuffer: ByteBuffer(string: capturedRoute.responseBody))
                    )
                }
            }

            let app = Application(
                router: router,
                configuration: .init(address: .hostname("127.0.0.1", port: port))
            )
            try await app.run()
        }
    }

    func stop() {
        serverTask?.cancel()
        serverTask = nil
    }
}

private let serverManager = ServerManager()

// MARK: - Client

public struct MockServerClient: Sendable {
    public var start: @Sendable (_ port: Int, _ routes: [MockRoute]) async throws -> Void
    public var stop: @Sendable () async throws -> Void

    public init(
        start: @Sendable @escaping (_ port: Int, _ routes: [MockRoute]) async throws -> Void,
        stop: @Sendable @escaping () async throws -> Void
    ) {
        self.start = start
        self.stop = stop
    }
}

// MARK: - Dependency

extension MockServerClient: DependencyKey {
    public static let liveValue = MockServerClient(
        start: { port, routes in
            await serverManager.start(port: port, routes: routes)
        },
        stop: {
            await serverManager.stop()
        }
    )

    public static let testValue = MockServerClient(
        start: { _, _ in },
        stop: { }
    )
}

extension DependencyValues {
    public var mockServerClient: MockServerClient {
        get { self[MockServerClient.self] }
        set { self[MockServerClient.self] = newValue }
    }
}
