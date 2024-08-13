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
            targets: ["AtomSDKTunnel"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AtomSDKTunnel",
            dependencies: ["AtomOVPNTunnel"],
            linkerSettings: [
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS])),
            ]),
        .target(
            name: "AtomOVPNTunnel",
            dependencies: [
                "mbedTLS",
                "OpenVPNClient"
            ],
            path: "AtomOVPNTunnel/Sources/AtomOVPNTunnel",
            sources: ["library"],
            cxxSettings: [
                .headerSearchPath("../ASIO/asio/include"),
                .headerSearchPath("../OpenVPN3"),
                .define("USE_ASIO")
            ]
        ),
        .target(
            name: "LZ4",
            path: "AtomOVPNTunnel/Sources/LZ4",
            sources: ["lib"],
            cSettings: [
                .define("XXH_NAMESPACE", to: "LZ4_")
            ]
        ),
        .target(
            name: "mbedTLS",
            path: "AtomOVPNTunnel/Sources/mbedTLS",
            sources: ["library"],
            cSettings: [
                .define("MBEDTLS_MD4_C"),
                .define("MBEDTLS_RELAXED_X509_DATE"),
                .define("_FILE_OFFSET_BITS", to: "64"),
            ]
        ),
        .target(
            name: "OpenVPNClient",
            dependencies: [
                "LZ4",
                "mbedTLS"
            ],
            path: "AtomOVPNTunnel/Sources/OpenVPNClient",
            sources: ["library"],
            cxxSettings: [
                .headerSearchPath("../ASIO/asio/include"),
                .headerSearchPath("../OpenVPN3"),
                .define("USE_ASIO"),
                .define("USE_ASIO_THREADLOCAL"),
                .define("ASIO_STANDALONE"),
                .define("ASIO_NO_DEPRECATED"),
                .define("ASIO_HAS_STD_STRING_VIEW"),
                .define("USE_MBEDTLS"),
                .define("HAVE_LZ4"),
                .define("OPENVPN_FORCE_TUN_NULL"),
                .define("USE_TUN_BUILDER")
            ]
        )
    ],
    cxxLanguageStandard: .gnucxx14
)
