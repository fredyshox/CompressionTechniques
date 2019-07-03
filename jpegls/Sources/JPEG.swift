//
//  JPEG.swift
//  lista4
//
//  Created by Kacper Raczy on 11.12.2018.
//

import Foundation
import TGAImage

class JPEG {

    let image: TGAImage

    init(image: TGAImage) {
        self.image = image
    }

    func encodeDifferences(using predictionStrategy: JPEGStrategy) -> TGAImage {
        var copy = image
        for y in 0..<image.height {
            for x in 0..<image.width {
                let original = try! image.get(x, y)
                let prediction = predictionStrategy.prediction(forPixelAt: (x,y), in: image)
                try! copy.set(x, y, newValue: original - prediction)
            }
        }

        return copy
    }

    static func imageEntropy(_ image: TGAImage) -> (total: Double, red: Double, green: Double, blue: Double) {
        var pixelFreq = [Int](repeating: 0, count: 256)
        var redFreq = [Int](repeating: 0, count: 256)
        var greenFreq = [Int](repeating: 0, count: 256)
        var blueFreq = [Int](repeating: 0, count: 256)
        for pixel in image.pixelValues {
            redFreq[Int(pixel.red)] += 1
            greenFreq[Int(pixel.green)] += 1
            blueFreq[Int(pixel.blue)] += 1
            for subp in [pixel.red, pixel.green, pixel.blue] {
                pixelFreq[Int(subp)] += 1
            }
        }

        let subpixelCount = image.width * image.height
        let pixelEntropy = entropy(freqArr: pixelFreq, dataLength: subpixelCount * 3)
        let redEntropy = entropy(freqArr: redFreq, dataLength: subpixelCount)
        let greenEntropy = entropy(freqArr: greenFreq, dataLength: subpixelCount)
        let blueEntropy = entropy(freqArr: blueFreq, dataLength: subpixelCount)

        return (pixelEntropy, redEntropy, greenEntropy, blueEntropy)
    }

    fileprivate static func entropy(freqArr: [Int], dataLength: Int) -> Double {
        var result = 0.0
        for value in freqArr where value != 0 {
            let prob = Double(value) / Double(dataLength)
            result += prob * -1 * log2(prob)
        }

        return result
    }

}
