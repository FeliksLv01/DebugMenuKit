// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "DebugMenuKitMacrosPackage",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "DebugMenuKitMacro", targets: ["DebugMenuKitMacro"]),
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
            ]
        ),
        .target(name: "DebugMenuKitMacro", dependencies: ["DebugMenuKitMacros"]),
    ]
)
