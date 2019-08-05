// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CoreDataAdvanced",
    products: [
        .library(
            name: "CoreDataAdvanced",
            targets: ["CoreDataAdvanced"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CoreDataAdvanced",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "CoreDataAdvancedTests",
            dependencies: ["CoreDataAdvanced"],
            path: "Tests"
        ),
    ]
)
