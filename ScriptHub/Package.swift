// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
            path: "ScriptHub",
            resources: [
                .copy("../scripts_config.json")
            ]
        )
    ]
)
