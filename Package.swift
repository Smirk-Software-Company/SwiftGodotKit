// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGodotKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftGodotKit",
            targets: ["SwiftGodotKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Smirk-Software-Company/SwiftGodot", branch: "main")
//        .package(path: "../SwiftGodot")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftGodotKit",
            dependencies: ["SwiftGodot", "libgodot"]),
        .binaryTarget(name: "libgodot", url: "https://github.com/Smirk-Software-Company/SmirkGodot/tree/main/libgodot.xcframework", checksum: "29e15279d596546758411a2c2192f5ef10e6328b"),
//        .binaryTarget (
//            name: "libgodot",
//            path: "../libgodot.xcframework"),
        .testTarget(
            name: "SwiftGodotKitTests",
            dependencies: ["SwiftGodotKit"]),
    ]
)
