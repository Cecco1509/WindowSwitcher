// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WindowSwitcher",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/LebJe/TOMLKit.git", from: "0.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "WindowSwitcher",
            dependencies: ["TOMLKit"],
            swiftSettings: [
                .unsafeFlags(["-import-objc-header", "Sources/WindowSwitcher/BridgingHeader.h"])
            ],
            linkerSettings:[
                .linkedFramework("CoreGraphics"),
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
            ]
        ),
        .testTarget(
            name: "WindowSwitcherTests",
            dependencies: ["WindowSwitcher"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
