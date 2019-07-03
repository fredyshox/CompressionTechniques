//
//  DifferentialCoder.swift
//  lista6
//
//  Created by Kacper Raczy on 15.01.2019.
//

import Foundation
import TGAImage

// MARK: Encoding & Decoding

public class DifferentialCoder {

    public let quantizerBits: UInt8

    public init(quantizerBits: UInt8) {
        self.quantizerBits = quantizerBits
    }

    public func decode(image: inout TGAImage) {
        for y in 0..<image.height {
            var prevRed: UInt8 = 0, prevGreen: UInt8 = 0, prevBlue: UInt8 = 0
            for (x, color) in (try! image.get(y)).enumerated() {
                prevRed = prevRed &+ color.red
                prevGreen = prevGreen &+ color.green
                prevBlue = prevBlue &+ color.blue
                try! image.set(x, y, newValue: .make(prevRed, prevGreen, prevBlue))
            }
        }
    }

    public func encode(image: inout TGAImage) {
        for y in 0..<image.height {
            var prevRed: UInt8 = 0, prevGreen: UInt8 = 0, prevBlue: UInt8 = 0
            for x in 0..<image.width {
                var color = try! image.get(x, y)
                // red
                let diffRed = color.red &- prevRed
                let predictionRed = prediction(for: color.red, predictionDifference: diffRed)
                (color.red, prevRed) = predictionRed
                // green
                let diffGreen = color.green &- prevGreen
                let predictionGreen = prediction(for: color.green, predictionDifference: diffGreen)
                (color.green, prevGreen) = predictionGreen
                // blue
                let diffBlue = color.blue &- prevBlue
                let predictionBlue = prediction(for: color.blue, predictionDifference: diffBlue)
                (color.blue, prevBlue) = predictionBlue
                // set the color
                try! image.set(x, y, newValue: color)
            }
        }
    }

    private func prediction(for value: UInt8, predictionDifference: UInt8) -> (q: UInt8, prediction: UInt8) {
        let q = quantizeMidtread(value: predictionDifference, bits: Int(quantizerBits))
        let qError = q &- predictionDifference
        let prediction = value &+ qError
        return (q, prediction)
    }

    private func quantizeMidtread(value: UInt8, bits: Int) -> UInt8 {
        let quantized = Int8(-1 << (8 - bits))
        return value & UInt8(bitPattern: quantized)
    }

}
