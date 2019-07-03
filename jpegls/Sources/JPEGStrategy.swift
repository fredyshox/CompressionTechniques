//
//  JPEG.swift
//  lista4
//
//  Created by Kacper Raczy on 11.12.2018.
//

import Foundation
import TGAImage

fileprivate let blackColor = TGAImage.Color.make(0, 0, 0)

enum JPEGStrategy: CaseIterable {
    case oneDim1
    case oneDim2
    case oneDim3
    case twoDim1
    case twoDim2
    case twoDim3
    case twoDim4
    case jpegls

    func prediction(forPixelAt coords: (x: Int,y: Int), in image: TGAImage) -> TGAImage.Color {
        let (x, y) = coords
        let a = (try? image.get(x - 1, y)) ?? blackColor
        let b = (try? image.get(x, y + 1)) ?? blackColor
        let c = (try? image.get(x - 1, y + 1)) ?? blackColor
        switch self {
        case .oneDim1:
            return a
        case .oneDim2:
            return b
        case .oneDim3:
            return c
        case .twoDim1:
            return a + b - c
        case .twoDim2:
            return a + (b - c)/2
        case .twoDim3:
            return b + (a - c)/2
        case .twoDim4:
            return (a + b)/2
        case .jpegls:
            let subpixels = [(a.red, b.red, c.red), (a.green, b.green, c.green), (a.blue, b.blue, c.blue)]
            var predictions: [UInt8] = []
            for (s1, s2, s3) in subpixels {
                // a, b, c
                var value: UInt8!
                if s3 >= max(s1, s2) {
                    value = min(s1, s2)
                } else if s3 <= min(s1, s2) {
                    value = max(s1, s2)
                } else {
                    value = (s1 &+ s2 &- s3)
                }
                predictions.append(value)
            }
            return TGAImage.Color.make(predictions[0], predictions[1], predictions[2])
        }
    }

}
