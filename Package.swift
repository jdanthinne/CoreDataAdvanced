// swift-tools-version:5.1

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
    ]
)
