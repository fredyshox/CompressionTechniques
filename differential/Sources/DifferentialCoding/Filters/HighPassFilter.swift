//
//  HighPassFilter.swift
//  lista6
//
//  Created by Kacper Raczy on 22.01.2019.
//

import Foundation
import TGAImage

struct Kernel {
    static var kernel1: Kernel {
        let matrix = [
            [-1.0, -1.0, -1.0],
            [-1.0,  8.0, -1.0],
            [-1.0, -1.0, -1.0]
        ]
        let factor = 1.0/8.0
        return Kernel(filterMatrix: matrix, scaleFactor: factor)
    }

    static var kernel2: Kernel {
        let matrix = [
            [0.0, -1.0, 0.0],
            [-1.0,  4.0, -1.0],
            [0.0, -1.0, 0.0]
        ]
        let factor = 1.0/4.0
        return Kernel(filterMatrix: matrix, scaleFactor: factor)
    }

    static var kernel3: Kernel {
        let matrix = [
            [1.0, -2.0, 1.0],
            [-2.0,  5.0, -2.0],
            [1.0, -2.0, 1.0]
        ]
        let factor = 1.0/5.0
        return Kernel(filterMatrix: matrix, scaleFactor: factor)
    }


    let filterMatrix: [[Double]]
    let scaleFactor: Double
}

class HighPassFilter: Filter {
    let kernelSize: Int
    let filterMatrix: [[Double]]
    let scaleFactor: Double

    init(kernel: Kernel) {
        self.kernelSize = kernel.filterMatrix.count
        self.filterMatrix = kernel.filterMatrix
        self.scaleFactor = kernel.scaleFactor
    }

    func apply(image: inout TGAImage) {
        let offset = kernelSize / 2
        for x in offset...(image.width - offset - 1) {
            for y in offset...(image.height - offset - 1) {
                var color = TGAImage.Color.make(0, 0, 0)
                var filtered: (red: Int, green: Int, blue: Int) = (0,0,0)
                for i in stride(from: -offset, through: offset, by: 1) {
                    for j in stride(from: -offset, through: offset, by: 1) {
                        let pixel = try! image.get(x + i, y + j)
                        let filterValue = filterMatrix[offset + i][offset + j]

                        filtered.red += Int(filterValue * Double(pixel.red) * scaleFactor)// + 128)
                        filtered.green += Int(filterValue * Double(pixel.green) * scaleFactor)// + 128)
                        filtered.blue += Int(filterValue * Double(pixel.blue) * scaleFactor)// + 128)
                    }
                }

                color.red = UInt8(clamping: filtered.red)
                color.green = UInt8(clamping: filtered.green)
                color.blue = UInt8(clamping: filtered.blue )
                try! image.set(x, y, newValue: color)
            }
        }
    }

    func apply(factor: Double) -> UInt8 {
        if factor < 0.0 {
            return UInt8.min
        } else if factor > Double(UInt8.max) {
            return UInt8.max
        } else {
            return UInt8(factor)
        }
    }

}
