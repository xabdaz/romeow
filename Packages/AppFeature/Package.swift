// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppFeature",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
        .package(path: "../SharedModels"),
        .package(path: "../RequestFeature"),
        .package(path: "../ResponseFeature"),
        .package(path: "../MockServerFeature")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SharedModels",
                "RequestFeature",
                "ResponseFeature",
                "MockServerFeature"
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: ["AppFeature"]
        )
    ]
)
