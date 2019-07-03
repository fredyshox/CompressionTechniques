//
//  UniversalDecodingStrategy.swift
//  encoder
//
//  Created by Kacper Raczy on 20.11.2018.
//

import Foundation

public enum UniversalDecodingStrategy {
    case eliasGamma
    case eliasDelta
    case eliasOmega
    case fibonacci
    
    public func decode(bitSet: BitSet) throws -> [UInt] {
        switch self {
        case .eliasGamma:
            return try decodeEliasGamma(bitSet: bitSet)
        case .eliasDelta:
            return try decodeEliasDelta(bitSet: bitSet)
        case .eliasOmega:
            return try decodeEliasOmega(bitSet: bitSet)
        case .fibonacci:
            return try decodeFibonacci(bitSet: bitSet)
        }
    }
    
}

enum UniversalCodeError: Error {
    case dataCorrupted
}

fileprivate func decodeEliasGamma(bitSet: BitSet) throws -> [UInt] {
    var numbers: [UInt] = []
    var counter = 0
    var nBitCount = 0
    var zerosFlag = true
    var n: UInt = 0
    while counter < bitSet.count {
        if zerosFlag {
            if !bitSet[counter] {
                nBitCount += 1
                counter += 1
            } else {
                zerosFlag = false
                nBitCount += 1
                n = 0
            }
        } else {
            if bitSet[counter] {
                n = n | UInt(0x01 << (nBitCount - 1))
            }
            nBitCount -= 1
            counter += 1
            
            if nBitCount == 0 {
                zerosFlag = true
                numbers.append(n)
            }
        }
    }
    
    return numbers
}

fileprivate func decodeEliasDelta(bitSet: BitSet) throws -> [UInt] {
    var numbers: [UInt] = []
    enum DeltaMode: Int {
        case zeros
        case bitLength
        case number
    }
    
    var counter = 0
    var mode = DeltaMode.zeros
    var bitCount: UInt = 0
    var countBitCount: UInt = 0
    var n: UInt = 0
    while counter < bitSet.count {
        if mode == .zeros {
            if !bitSet[counter] {
                counter += 1
            } else {
                mode = .bitLength
                bitCount = 0
            }
            countBitCount += 1
        } else if mode == .bitLength {
            if bitSet[counter] {
                bitCount = bitCount | UInt(0x01 << (countBitCount - 1))
            }
            countBitCount -= 1
            counter += 1
            if countBitCount == 0 {
                n = n | UInt(0x01 << (bitCount - 1))
                bitCount -= 1
                if bitCount  == 0 {
                    numbers.append(n)
                    n = 0
                    mode = .zeros
                } else {
                    mode = .number
                }
            }
        } else {
            if bitSet[counter] {
                n = n | UInt(0x01 << (bitCount - 1))
            }
            bitCount -= 1
            counter += 1
            if bitCount == 0 {
                numbers.append(n)
                n = 0
                mode = .zeros
            }
        }
    }
    
    return numbers
}

fileprivate func decodeEliasOmega(bitSet: BitSet) throws -> [UInt] {
    var numbers: [UInt] = []
    var counter = 0
    var n: UInt = 1
    var temp: UInt = 0
    
    while counter < bitSet.count {
        if bitSet[counter] {
            var i = 0
            while i < n + 1 && counter + i < bitSet.count {
                if bitSet[counter + i] {
                    temp = temp | UInt(0x01 << (n - UInt(i)))
                }
                i += 1
            }
            counter = counter + i
            n = temp
            temp = 0
        } else {
            numbers.append(n)
            n = 1
            counter += 1
        }
    }
    
    return numbers
}

fileprivate func decodeFibonacci(bitSet: BitSet) throws -> [UInt] {
    var numbers: [UInt] = []
    var n: UInt = 0
    var counter = 1
    var prev: Bool = false
    for i in 0..<bitSet.count {
        let bit = bitSet[i]
        if prev && bit {
            numbers.append(n)
            n = 0 
            counter = 1
            prev = false
            continue
        }
        
        if bit {
            n += UInt(fib(counter))
        }
        counter += 1
        prev = bit
    }
    
    return numbers
}
