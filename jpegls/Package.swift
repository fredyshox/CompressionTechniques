// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "losslessJPEG",
    dependencies: [
      .package(path: "../tga")
    ],
    targets: [
        .target(
            name: "jpegls-predictor",
            dependencies: [
              .product(name: "TGAImage")
            ],
            path: "Sources/"),
    ]
)
