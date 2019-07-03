//
//  LZWDecoder.swift
//  encoder
//
//  Created by Kacper Raczy on 19.11.2018.
//

import Foundation

public class LZWDecoder {
    
    public enum DecodingError: Error {
        case dataCorrupted
        case incompatibleFormat
    }
    
    public var dataDecodingStrategy: UniversalDecodingStrategy = .eliasGamma
    
    public init() {}
    
    public func decode(_ data: Data) throws -> Data {
        guard let padding = data.first else {
            throw DecodingError.incompatibleFormat
        }
        let bitSet = BitSet(bytes: [UInt8](data.advanced(by: 1)), padding: Int(padding))
        var inputCodes: [UInt] = try dataDecodingStrategy.decode(bitSet: bitSet)
        // decrement all codes to get ascii codes
        inputCodes = inputCodes.map({ $0 - 1 })
        var outputData = Data()
        var dict: [UInt: [UInt8]] = [:]
        for i in 0...255 as ClosedRange<UInt8> {
            dict[UInt(i)] = [i]
        }
        var iterator = inputCodes.makeIterator()
        var topCode: UInt = 256
        var buffer: [UInt8]!
        var prev: [UInt8] = dict[iterator.next()!]!
        outputData.append(contentsOf: prev)
        while let code = iterator.next() {
            if dict.keys.contains(code) {
                buffer = dict[code]
            } else if code == topCode {
                buffer = prev + [prev[0]]
            } else {
                throw DecodingError.dataCorrupted
            }
            
            outputData.append(contentsOf: buffer)
            dict[topCode] = prev + [buffer[0]]
            topCode += 1
            prev = buffer
        }
        
        return outputData
    }
    
}
