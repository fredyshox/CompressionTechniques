//
//  ImageQuantizer.swift
//  quantizer
//
//  Created by Kacper Raczy on 18.12.2018.
//

import Foundation
import TGAImage

public class ImageQuantizer {

    enum ColorComponent {
        case red
        case green
        case blue
    }

    public let bitsPerRGB: (red: UInt8, green: UInt8, blue: UInt8)
    private let levelCountRGB: (red: UInt8, green: UInt8, blue: UInt8)
    private lazy var stepSizeRGB: (red: Int, green: Int, blue: Int) = {
        let stepSizeRed = 256 / Int(levelCountRGB.red)
        let stepSizeGreen = 256 / Int(levelCountRGB.green)
        let stepSizeBlue = 256 / Int(levelCountRGB.blue)
        return (stepSizeRed, stepSizeGreen, stepSizeBlue)
    }()

    public init(bitsPerRGB red: UInt8, _ green: UInt8, _ blue: UInt8) {
        let levelCountRed = UInt8(0x01 << red)
        let levelCountGreen = UInt8(0x01 << green)
        let levelCountBlue = UInt8(0x01 << blue)
        self.levelCountRGB = (levelCountRed, levelCountGreen, levelCountBlue)
        self.bitsPerRGB = (red, green, blue)
    }

    private func quantizeMidrise(value: UInt8, stepSize: Int) -> UInt8 {
        // Int(v/stepSize) * stepSize + stepSize / 2
        // stepSize / 2 if f <= fmin
        // 256 - stepsize/2 if f > fmax
        var quantized = (Int(value) / stepSize) * stepSize + stepSize / 2
        if quantized == 0 {
            quantized = stepSize / 2
        } else if quantized > UInt8.max {
            quantized = 256 - stepSize / 2
        }

        fatalError()
    }

    private func quantizeMidtread(value: UInt8, component: ColorComponent) -> UInt8 {
        var bits: UInt8 = 0
        switch component {
        case .red:
            bits = bitsPerRGB.red
        case .green:
            bits = bitsPerRGB.green
        case .blue:
            bits = bitsPerRGB.blue
        }

        let quantized = Int8(-1 << (8 - Int(bits)))
        return value & UInt8(bitPattern: quantized)
    }

    private func quantizeMidtread(color: TGAImage.Color) -> TGAImage.Color {
        let qRed = quantizeMidtread(value: color.red, component: .red)
        let qGreen = quantizeMidtread(value: color.green, component: .green)
        let qBlue = quantizeMidtread(value: color.blue, component: .blue)
        return TGAImage.Color.make(qRed, qGreen, qBlue)
    }

    public func quantize(image: inout TGAImage) -> TGAImage {
        var imageCpy = image
        for x in 0..<image.width {
            for y in 0..<image.height {
                let color = try! image.get(x, y)
                let quantizedColor = quantizeMidtread(color: color)
                try! imageCpy.set(x, y, newValue: quantizedColor)
            }
        }

        return imageCpy
    }

}
