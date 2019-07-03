//
//  main.swift
//  quantizer
//
//  Created by Kacper Raczy on 18.12.2018.
//

import Foundation
import TGAImage

struct ArgumentError: LocalizedError {
    var localizedDescription: String {
        return "Invalid arguments"
    }
}

guard CommandLine.arguments.count > 5 else {
    fputs("Usage: program inFile outFile bitsPerRed bitsPerGreen bitsPreBlue\n", stderr)
    exit(1)
}

do {
    let srcPath = CommandLine.arguments[1]
    let destPath = CommandLine.arguments[2]
    guard let bitsPerRed = UInt8(CommandLine.arguments[3]),
        let bitsPerGreen = UInt8(CommandLine.arguments[4]),
        let bitsPerBlue = UInt8(CommandLine.arguments[5]) else {
        throw ArgumentError()
    }

    let image = try TGAImage(contentsOf: srcPath)
    let quantizer = ImageQuantizer(bitsPerRGB: bitsPerRed, bitsPerGreen, bitsPerBlue)
    let outImage = quantizer.quantize(image: image)
    let destUrl = URL(fileURLWithPath: destPath)
    try outImage.data().write(to: destUrl)
} catch let error {
    fputs("Error: \(error.localizedDescription)\n", stderr)
    exit(2)
}
