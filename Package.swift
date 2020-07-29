// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "EagleFramework",

    targets: [
        .target(name: "Base"),
        .target(name: "Database", dependencies: ["Base"]),
        .target(name: "Http", dependencies: ["Base", "Network", "Template"]),
        .target(name: "Network", dependencies: ["Base"]),
        .target(name: "Template", dependencies: ["Base"]),

        .target(name: "EagleServer", dependencies: ["Base", "Database", "Http", "Network"]),
        .target(name: "EagleTests", dependencies: ["Base", "Database", "Template"])
    ]
)
