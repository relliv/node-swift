// swift-tools-version:6.0

import PackageDescription
import CompilerPluginSupport
import Foundation

let buildDynamic = ProcessInfo.processInfo.environment["NODE_SWIFT_BUILD_DYNAMIC"] == "1"

let package = Package(
    name: "node-swift",
    platforms: [
        .macOS(.v10_15), .iOS(.v13),
    ],
    products: [
        .library(
            name: "NodeAPI",
            type: buildDynamic ? .dynamic : nil,
            targets: ["NodeAPI"]
        ),
        .library(
            name: "NodeJSC",
            targets: ["NodeJSC"]
        ),
        .library(
            name: "NodeModuleSupport",
            targets: ["NodeModuleSupport"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", "509.0.0"..."600.0.0-prerelease"),
    ],
    targets: [
        .systemLibrary(name: "CNodeAPI"),
        .target(
            name: "CNodeJSC",
            linkerSettings: [
                .linkedFramework("JavaScriptCore"),
            ]
        ),
        .target(
            name: "NodeJSC",
            dependencies: [
                "CNodeJSC",
                "NodeAPI",
            ]
        ),
        .target(name: "CNodeAPISupport"),
        .macro(
            name: "NodeAPIMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "NodeAPI",
            dependencies: ["CNodeAPI", "CNodeAPISupport", "NodeAPIMacros"]
        ),
        .target(
            name: "NodeModuleSupport",
            dependencies: ["CNodeAPI"]
        ),
        .testTarget(
            name: "NodeJSCTests",
            dependencies: ["NodeJSC", "NodeAPI"]
        ),
    ],
    swiftLanguageVersions: [.v5, .v6],
    cxxLanguageStandard: .cxx17
)
