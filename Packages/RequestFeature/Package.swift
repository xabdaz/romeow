// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RequestFeature",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "RequestFeature", targets: ["RequestFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
        .package(path: "../SharedModels"),
        .package(path: "../AppClients")
    ],
    targets: [
        .target(
            name: "RequestFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SharedModels",
                "AppClients"
            ]
        ),
        .testTarget(
            name: "RequestFeatureTests",
            dependencies: ["RequestFeature"]
        )
    ]
)
