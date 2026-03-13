// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppClients",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "AppClients", targets: ["AppClients"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
        .package(path: "../SharedModels")
    ],
    targets: [
        .target(
            name: "AppClients",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "AppClientsTests",
            dependencies: ["AppClients"]
        )
    ]
)
