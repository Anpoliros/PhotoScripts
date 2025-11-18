// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ScriptHub",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ScriptHub",
            targets: ["ScriptHub"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ScriptHub",
            dependencies: [],
            path: "ScriptHubApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
