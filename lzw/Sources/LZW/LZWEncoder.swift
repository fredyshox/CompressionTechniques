//
//  LZWEncoder.swift
//  encoder
//
//  Created by Kacper Raczy on 19.11.2018.
//

import Foundation

public class LZWEncoder {
    
    public var dataEncodingStrategy: UniversalEncodingStrategy = .eliasGamma
    
    public init() {}
    
    public func encode(_ data: Data) -> Data {
        var dict = [[UInt8]: UInt]()
        var outputCodes: [UInt] = []
        for i in 0...255 as ClosedRange<UInt8> {
            dict[[i]] = UInt(i)
        }
        
        var iterator = data.makeIterator()
        var topCode: UInt = 256
        var buffer: [UInt8] = []
        while let byte = iterator.next() {
            let temp = buffer + [byte]
            if dict.keys.contains(temp) {
                buffer.append(byte)
            } else {
                outputCodes.append(dict[buffer]!)
                dict[temp] = topCode
                buffer = [byte]
                topCode += 1
            }
        }
        outputCodes.append(dict[buffer]!)
        // icrement all codes to remove zeros
        outputCodes = outputCodes.map({ $0 + 1 })
        
        var outputData = Data()
        let outputBitSet = dataEncodingStrategy.encode(numbers: outputCodes)
        outputData.append(UInt8(outputBitSet.padding))
        outputData.append(contentsOf: outputBitSet.bytes)

        return outputData
    }
    
}
