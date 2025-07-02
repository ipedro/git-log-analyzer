// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GitLogAnalyzer",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "git-log-analyzer",
            targets: ["GitLogAnalyzer"]
        ),
        .library(
            name: "Git",
            targets: ["Git"]
        ),
        .library(
            name: "FileIndexer",
            targets: [
                "FileIndexer"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-tools-support-core", from: "0.7.3"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.1"),
    ],
    targets: [
        .executableTarget(
            name: "GitLogAnalyzer",
            dependencies: [
                "Git",
                "FileIndexer",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport", package: "swift-tools-support-core")
            ]
        ),
        .target(name: "Git"),
        .target(name: "FileIndexer"),
        .testTarget(name: "GitTests"),
        .testTarget(name: "FileIndexerTests"),
    ]
)
