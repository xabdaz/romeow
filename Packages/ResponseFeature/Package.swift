// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ResponseFeature",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ResponseFeature", targets: ["ResponseFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
        .package(path: "../SharedModels")
    ],
    targets: [
        .target(
            name: "ResponseFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SharedModels"
            ]
        ),
        .testTarget(
            name: "ResponseFeatureTests",
            dependencies: ["ResponseFeature"]
        )
    ]
)
