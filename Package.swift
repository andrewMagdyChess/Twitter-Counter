// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Twitter-Counter",
    platforms: [
         .macOS(.v10_13),
         .iOS(.v13),
         .tvOS(.v13),
         .watchOS(.v3)
     ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Twitter-Counter",
            targets: ["Twitter-Counter"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/mironal/TwitterAPIKit.git", from: "0.2.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Twitter-Counter",
            dependencies: ["TwitterAPIKit"]),
        .testTarget(
            name: "Twitter-CounterTests",
            dependencies: ["Twitter-Counter"]),
    ]
)
//product 'twitter-text' required by package 'twitter-counter' target 'Twitter-Counter' not found.
