// swift-tools-version: 6.0
import PackageDescription

let targets: [Target] = [
    .executableTarget(
        name: "MacsteamApp",
        path: "Sources/MacsteamApp",
        resources: [.process("Resources")]
    ),
    .testTarget(
        name: "MacsteamAppTests",
        dependencies: ["MacsteamApp"],
        path: "Tests/MacsteamAppTests"
    ),
]

let package = Package(
    name: "MacsteamApp",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    targets: targets
)
