// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MovePlannerApp",
    platforms: [
        .iOS(.v17),
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
