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
        .binaryTarget(name: "libgodot", url: "https://github.com/Smirk-Software-Company/SwiftGodotKit/raw/76c2ae03151c30f9a7a7fa890ec8dbb1781becd1/libgodot.xcframework.zip", checksum: "16f54f90ae55ed425cfb1e19528b9e0a14f009411c92bd04db504f730b6dac5e"),
//        .binaryTarget (
//            name: "libgodot",
//            path: "../libgodot.xcframework"),
        .testTarget(
            name: "SwiftGodotKitTests",
            dependencies: ["SwiftGodotKit"]),
    ]
)
