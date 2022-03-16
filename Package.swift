// swift-tools-version:5.6

import PackageDescription

#if os(Linux)
let package = Package(
    name: "EagleFramework",

    targets: [
        .systemLibrary(name: "CEpoll"),
        .systemLibrary(name: "CSQLite3Linux"),

        .target(name: "Base"),
        .target(name: "Database", dependencies: ["Base", "CSQLite3Linux"]),
        .target(name: "Http", dependencies: ["Base", "Network", "Template"]),
        .target(name: "Network", dependencies: ["Base", "CEpoll"]),
        .target(name: "Template", dependencies: ["Base"]),

        .target(name: "EagleServer", dependencies: ["Base", "Database", "Http", "Network"]),
        .target(name: "EagleTests", dependencies: ["Base", "Database", "Template"])
    ]
)
#else
let package = Package(
    name: "EagleFramework",

    targets: [
        .target(name: "Base"),
        .testTarget(name: "BaseTests", dependencies: ["Base"]),

        .target(name: "Database", dependencies: ["Base"]),
        .testTarget(name: "DatabaseTests", dependencies: ["Database"]),

        .target(name: "Http", dependencies: ["Base", "Network", "Template"]),
        .target(name: "Network", dependencies: ["Base"]),
        .target(name: "Template", dependencies: ["Base"]),

        .executableTarget(name: "EagleServer", dependencies: ["Base", "Database", "Http", "Network"])
    ]
)
#endif
