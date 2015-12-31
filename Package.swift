import PackageDescription

let package = Package(
    name: "SwiftHTTPServer",
    targets: [
        Target(name: "Base"),
        Target(name: "Http", dependencies: [.Target(name: "Base"),
                                            .Target(name: "Network"),
                                            .Target(name: "Template")]),
        Target(name: "Network", dependencies: [.Target(name: "Base")]),
        Target(name: "Template", dependencies: [.Target(name: "Base")]),

        Target(name: "SwiftHTTPServer", dependencies: [.Target(name: "Base"),
                                                       .Target(name: "Http"),
                                                       .Target(name: "Network")])
    ]
)
