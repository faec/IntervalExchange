// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let deps = [
  Package.Dependency.package(url: "../Modules/CGmp", from: "1.0.0"),
  Package.Dependency.package(url: "../Modules/Clibbsd", from: "1.0.0"),
]

let package = Package(
    name: "IntervalExchange",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "IntervalLib",
            type: .dynamic,
            targets: ["IntervalLib"]),
    ],
    dependencies: deps,
    targets: [
        .target(
            name: "IntervalTool",
            dependencies: ["IntervalLib"]),
        .target(
            name: "IntervalLib"),
        .testTarget(
            name: "IntervalLibTests",
            dependencies: ["IntervalLib"]),
    ]
)
