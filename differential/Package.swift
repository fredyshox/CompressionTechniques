// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lista6",
    products: [
        .library(name: "DifferentialCoding", targets: ["DifferentialCoding"]),
        .executable(name: "encoder", targets: ["encoder"]),
        .executable(name: "decoder", targets: ["decoder"])
    ],
    dependencies: [
      .package(path: "../tga")
    ],
    targets: [
        .target(
            name: "DifferentialCoding",
            dependencies: [
              .product(name: "TGAImage")
            ]),
        .target(
            name: "encoder",
            dependencies: [
              "DifferentialCoding",
              .product(name: "TGAImage")
            ],
            path: "Sources/encoder"),
        .target(
            name: "decoder",
            dependencies: [
              "DifferentialCoding",
              .product(name: "TGAImage")
            ],
            path: "Sources/decoder")
    ]
)
