// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "DebugMenuKit",
    platforms: [
        .iOS(.v15),
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
            path: "DebugMenuKitMacros/Sources/DebugMenuKitMacros"
        ),
        .target(
            name: "DebugMenuKitMacro",
            dependencies: ["DebugMenuKitMacros"],
            path: "DebugMenuKitMacros/Sources/DebugMenuKitMacro"
        ),
        .target(
            name: "DebugMenuKit",
            dependencies: ["DebugMenuKitMacro"],
            path: "Sources"
        ),
        .testTarget(
            name: "DebugMenuKitTests",
            dependencies: ["DebugMenuKit"]
        ),
    ]
)
