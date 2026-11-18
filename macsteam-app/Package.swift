// swift-tools-version: 6.0
import Foundation
import PackageDescription

var targets: [Target] = [
    .executableTarget(
        name: "MacsteamApp",
        path: "Sources/MacsteamApp"
    )
]

if FileManager.default.fileExists(atPath: "Tests/MacsteamAppTests") {
    targets.append(.testTarget(
        name: "MacsteamAppTests",
        dependencies: ["MacsteamApp"],
        path: "Tests/MacsteamAppTests"
    ))
}

let package = Package(
    name: "MacsteamApp",
    platforms: [
        .macOS(.v13)
    ],
    targets: targets
)
