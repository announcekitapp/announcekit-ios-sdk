// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnnounceKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "AnnounceKit",
            targets: ["AnnounceKit"]),
    ],
    targets: [
        .target(
            name: "AnnounceKit",
            dependencies: [])
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
