// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Quantization",
    dependencies: [
      .package(path: "../tga")
    ],
    targets: [
        .target(
            name: "quantizer",
            dependencies: [
              .product(name: "TGAImage")
            ],
            path: "Sources/")
    ]
)
