// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtomSDKTunnel",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "AtomSDKTunnel",
            targets: ["AtomSDKTunnel"]),
    ],
    dependencies: [
        .package(path: "./AtomOVPNTunnel")
    ],
    targets: [
        .target(
            name: "AtomSDKTunnel",dependencies: ["AtomOVPNTunnel"],linkerSettings: [
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS])),
            ]),
    ]
)
