// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MovePlannerApp",
    platforms: [
        .iOS(.v18),
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MovePlannerApp", targets: ["MovePlannerApp"])
    ],
    targets: [
        .executableTarget(
            name: "MovePlannerApp",
            path: "Sources/MovePlannerApp"
        )
    ]
)
