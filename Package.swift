// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "GitLogAnalyser",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "git-log-analyser",
            targets: ["GitLogAnalyser"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-tools-support-core", from: "0.7.3"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.1"),
    ],
    targets: [
        .executableTarget(
            name: "GitLogAnalyser",
            dependencies: [
                "GitLibrary",
                "FileEnumerationLibrary",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport", package: "swift-tools-support-core")
            ]
        ),
        .target(name: "GitLibrary"),
        .target(name: "FileEnumerationLibrary"),
        .testTarget(name: "GitLibraryTests"),
        .testTarget(name: "FileEnumerationLibraryTests"),
    ]
)
