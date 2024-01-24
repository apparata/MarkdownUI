// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "MarkdownUI",
    platforms: [
        // Relevant platforms.
        .iOS(.v15), .macOS(.v12), .tvOS(.v15)
    ],
    products: [
        .library(name: "MarkdownUI", targets: ["MarkdownUI"])
    ],
    dependencies: [
        // It's a good thing to keep things relatively
        // independent, but add any dependencies here.
    ],
    targets: [
        .target(
            name: "MarkdownUI",
            dependencies: [],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]),
        .testTarget(name: "MarkdownUITests", dependencies: ["MarkdownUI"]),
    ]
)
