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
        .binaryTarget(name: "libgodot", url: "https://github.com/Smirk-Software-Company/SmirkGodot/tree/main/libgodot.xcframework.zip", checksum: "8d5d41959ae70785a7606f27afa588aca73f8e30"),
//        .binaryTarget (
//            name: "libgodot",
//            path: "../libgodot.xcframework"),
        .testTarget(
            name: "SwiftGodotKitTests",
            dependencies: ["SwiftGodotKit"]),
    ]
)
