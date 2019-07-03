//
//  BitSet.swift
//  LZW Compression
//
//  Created by Kacper Raczy on 19.11.2018.
//

import Foundation

let kBinLeadingOne8: UInt8 = 0x80
let kBinLeadingOne32: UInt32 = 0x80000000
let kBinLeadingOne64: UInt64 = 0x8000000000000000

public struct BitSet {
    private var pointer: Int = 0
    public private(set) var count: Int
    public private(set) var bytes: [UInt8]
    
    public init(bytes: [UInt8] = [], count: Int = 0) {
        self.bytes = bytes
        self.count = count
        self.pointer = count % 8
    }
    
    public init(bytes: [UInt8], padding: Int) {
        let count = bytes.count * 8 - padding
        self.init(bytes: bytes, count: count)
    }
    
    public mutating func set(bitIndex: Int, value: Bool = true) {
        let (block, inBlockIndex) = bitIndex.quotientAndRemainder(dividingBy: 8)
        var newValue: UInt8 = 0
        if value {
            newValue = bytes[block] | (kBinLeadingOne8 >> inBlockIndex)
        } else {
            newValue = bytes[block] & ~(kBinLeadingOne8 >> inBlockIndex)
        }
        bytes[block] = newValue
    }
    
    public mutating func add(value: Bool) {
        if pointer == 0 {
            bytes.append(0x00)
        }
        
        if value {
            var lastByte = bytes.last!
            lastByte = lastByte | kBinLeadingOne8 >> pointer
            bytes[bytes.count - 1] = lastByte
        }
        
        pointer = (pointer + 1) % 8
        count += 1
    }
    
    public mutating func add(repeating value: Bool, count: Int) {
        for _ in 0..<count {
            self.add(value: value)
        }
    }
    
    public mutating func add(bitSet: BitSet) {
        for i in 0..<bitSet.count {
            self.add(value: bitSet[i])
        }
    }
    
    public mutating func add(integer: UInt) {
        let bitCount = integer.bitWidth - integer.leadingZeroBitCount
        var binLeadingOne: UInt!
        switch integer.bitWidth {
        case 64:
            binLeadingOne = UInt(kBinLeadingOne64)
        case 32:
            binLeadingOne = UInt(kBinLeadingOne32)
        default:
            return 
        }
        
        for i in 0..<bitCount {
            let value = (integer & (binLeadingOne >> UInt(integer.leadingZeroBitCount + i))) != 0
            self.add(value: value)
        }
    }
    
    public func get(bitIndex: Int) -> Bool {
        let (block, inBlockIndex) = bitIndex.quotientAndRemainder(dividingBy: 8)
        let value = bytes[block]
        return (value & (kBinLeadingOne8 >> inBlockIndex)) != 0
    }
    
    public func reversed() -> BitSet {
        let zeroedBytes = [UInt8](repeating: 0, count: self.bytes.count)
        var reversedBs = BitSet(bytes: zeroedBytes, count: self.count)
        reversedBs.pointer = 0
        for i in 0..<count {
            reversedBs.set(bitIndex: count - 1 - i, value: get(bitIndex: i))
        }
        
        return reversedBs
    }
    
    public var padding: Int {
        return bytes.count * 8 - count
    }
    
    public var data: Data {
        return Data(bytes)
    }
    
    public subscript(index: Int) -> Bool {
        get {
            return get(bitIndex: index)
        }
        set(newValue) {
            set(bitIndex: index, value: newValue)
        }
    }
    
}
