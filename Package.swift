// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "UIEnvironment",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "UIEnvironment",
            targets: [
                "UIEnvironment",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", exact: "1.1.4"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "601.0.1"),
    ],
    targets: [
        .target(
            name: "UIEnvironment",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                "UIEnvironmentMacro",
            ]
        ),
        .macro(
            name: "UIEnvironmentMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "UIEnvironmentTests",
            dependencies: ["UIEnvironment"]
        ),
    ]
)
