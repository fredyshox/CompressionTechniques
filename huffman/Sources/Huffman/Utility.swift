//
//  Utility.swift
//  huffman
//
//  Created by Kacper Raczy on 06.11.2018.
//

import Foundation

let kBinLeadingOne: UInt64 = 0x8000000000000000
let kBinLeadingOne8: UInt8 = 0x80

struct BinarySymbol {
    let value: UInt64
    let length: UInt8
}

struct BinaryQueue {
    let kByteLength: Int = 8
    private(set) var pointer: Int = 0
    private(set) var length: Int = 0
    var bytes: [UInt8] = []
    
    init(bytes: [UInt8] = [], padding: Int = 0) {
        self.bytes = bytes
        self.length = bytes.count * 8 - padding
    }
    
    mutating func nextBit(_ bit: Bool) {
        if pointer == 0 {
            bytes.append(0x00)
        }
        
        if bit {
            var lastByte = bytes.last!
            lastByte = lastByte | 0x80 >> pointer
            bytes[bytes.count - 1] = lastByte
        }
        
        pointer = (pointer + 1) % 8
        length += 1
    }
    
    func bit(at index: Int) -> Bool {
        let (block, bIndex) = index.quotientAndRemainder(dividingBy: 8)
        let value = bytes[block]
        return (value & (kBinLeadingOne8 >> bIndex)) != 0
    }
    
    func byte(from index: Int) -> UInt8 {
        let (block, bIndex) = index.quotientAndRemainder(dividingBy: 8)
        var value = bytes[block] << bIndex
        if bIndex > 0 {
            let restValue = bytes[block + 1] >> bIndex
            value = value | restValue
        }
        
        return value
    }
    
    var padding: Int {
        return bytes.count * 8 - length
    }
    
    var data: Data {
        return Data(bytes)
    }
}

extension BinaryQueue {
    mutating func nextBits(_ symbol: BinarySymbol) {
        for i in 0..<symbol.length {
            nextBit((symbol.value & kBinLeadingOne >> i) != 0)
        }
    }
    
    mutating func nextBits(_ byte: UInt8) {
        for i in 0..<byte.bitWidth {
            nextBit((byte & kBinLeadingOne8 >> i) != 0)
        }
    }
}

func printErr(_ str: String = "") {
    fputs("\(str)\n", stderr)
}
