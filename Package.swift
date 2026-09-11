// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "DebugMenuKit",
    platforms: [
        .iOS(.v15),
        // Required by the SwiftSyntax compiler-plugin host, not runtime support.
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "DebugMenuKit",
            targets: ["DebugMenuKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "603.0.0"),
    ],
    targets: [
        .macro(
            name: "DebugMenuKitMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "Sources/DebugMenuKitMacros"
        ),
        .target(
            name: "DebugMenuKit",
            dependencies: ["DebugMenuKitMacros"],
            path: "Sources/DebugMenuKit"
        ),
        .testTarget(
            name: "DebugMenuKitTests",
            dependencies: ["DebugMenuKit"]
        ),
        .testTarget(
            name: "DebugMenuKitMacrosTests",
            dependencies: [
                "DebugMenuKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
