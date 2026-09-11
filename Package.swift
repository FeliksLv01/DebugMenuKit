// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DebugMenuKit",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "DebugMenuKit",
            targets: ["DebugMenuKit"]
        ),
    ],
    dependencies: [
        .package(path: "Macros"),
    ],
    targets: [
        .target(
            name: "DebugMenuKit",
            dependencies: [
                .product(name: "DebugMenuKitMacro", package: "macros"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "DebugMenuKitTests",
            dependencies: ["DebugMenuKit"]
        ),
    ]
)
