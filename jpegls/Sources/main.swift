//
//  main.swift
//  lista4
//
//  Created by Kacper Raczy on 04.12.2018.
//

import Foundation
import TGAImage

func printEntropies(_ entropies: (Double, Double, Double, Double)) {
    let (total, red, green, blue) = entropies
    print("\t total: \(total) \n\t red: \(red) \n\t green: \(green) \n\t blue: \(blue)")
}

guard CommandLine.arguments.count > 1 else {
    print("Usage: program inputFile")
    exit(1)
}

let path = CommandLine.arguments[1]
do {
    let image = try TGAImage(contentsOf: path)
    let originalEntropies = JPEG.imageEntropy(image)
    print("Original: ")
    printEntropies(originalEntropies)

    let jpeg = JPEG(image: image)
    var compressed: TGAImage!
    var minEntropies = (total: DBL_MAX, red: DBL_MAX, green: DBL_MAX, blue: DBL_MAX)
    var minStrategies = (total: JPEGStrategy.oneDim1, red: JPEGStrategy.oneDim1, green: JPEGStrategy.oneDim1, blue: JPEGStrategy.oneDim1)
    for strategy in JPEGStrategy.allCases {
        compressed = jpeg.encodeDifferences(using: strategy)
        let compressedEntropies = JPEG.imageEntropy(compressed)
        if compressedEntropies.total < minEntropies.total {
            minEntropies.total = compressedEntropies.total
            minStrategies.total = strategy
        }
        if compressedEntropies.red < minEntropies.red {
            minEntropies.red = compressedEntropies.red
            minStrategies.red = strategy
        }
        if compressedEntropies.green < minEntropies.green {
            minEntropies.green = compressedEntropies.green
            minStrategies.green = strategy
        }
        if compressedEntropies.blue < minEntropies.blue {
            minEntropies.blue = compressedEntropies.blue
            minStrategies.blue = strategy
        }
        print("Strategy - \(strategy)")
        print("Compressed: ")
        printEntropies(compressedEntropies)
    }

    print(minStrategies)
} catch let error {
    print("Error: \(error.localizedDescription)")
    exit(2)
}
