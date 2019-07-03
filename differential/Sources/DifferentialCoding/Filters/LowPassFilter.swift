//
//  LowPassFilter.swift
//  lista6
//
//  Created by Kacper Raczy on 22.01.2019.
//

import Foundation
import TGAImage

class LowPassFilter: Filter {
    let kernelSize: Int
    var factor: UInt8 {
        return UInt8(kernelSize) &* UInt8(kernelSize)
    }

    init(kernelSize: Int) {
        guard kernelSize % 2 == 1 else {
            fatalError("Even kernelSize: \(kernelSize)")
        }

        self.kernelSize = kernelSize
    }

    func apply(image: inout TGAImage) {
        let offset = kernelSize / 2
        for x in offset...(image.width - offset - 1) {
            for y in offset...(image.height - offset - 1) {
                var color = TGAImage.Color.make(0, 0, 0)
                for i in stride(from: -offset, through: offset, by: 1) {
                    for j in stride(from: -offset, through: offset, by: 1) {
                        let pixel = try! image.get(x + i, y + j)
                        color.red = color.red &+ (pixel.red / factor)
                        color.green = color.green &+  (pixel.green / factor)
                        color.blue = color.blue &+ (pixel.blue / factor)
                    }
                }
                try! image.set(x, y, newValue: color)
            }
        }
    }

}
