// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "huffman",
    products: [
      .library(name: "Huffman", targets: ["Huffman"]),
      .executable(name: "encoder", targets: ["encoder"]),
      .executable(name: "decoder", targets: ["decoder"])
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
          name: "Huffman",
          dependencies: []),
        .target(
            name: "encoder",
            dependencies: ["Huffman"]),
        .target(
            name: "decoder",
            dependencies: ["Huffman"]),
    ]
)
