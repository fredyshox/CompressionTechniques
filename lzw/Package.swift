// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LZW Compression",
    products: [
      .library(name: "LZW", targets: ["LZW"]),
      .executable(name: "encoder", targets: ["encoder"]),
      .executable(name: "decoder", targets: ["decoder"])
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.3.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
          name: "LZW",
          dependencies: []),
        .target(
            name: "encoder",
	          dependencies: ["LZW", "SwiftPM"]),
      	.target(
      	    name: "decoder",
            dependencies: ["LZW", "SwiftPM"]),
        .testTarget(
          name: "LZWTests",
          dependencies: ["LZW"])
    ]
)
