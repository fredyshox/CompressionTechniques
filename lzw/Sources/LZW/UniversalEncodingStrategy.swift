//
//  UniversalCode.swift
//  encoder
//
//  Created by Kacper Raczy on 19.11.2018.
//

import Foundation

public enum UniversalEncodingStrategy {
    case eliasGamma
    case eliasDelta
    case eliasOmega
    case fibonacci
    
    public func encode(numbers: [UInt]) -> BitSet {
        switch self {
        case .eliasGamma:
            return encodeEliasGamma(numbers: numbers)
        case .eliasDelta:
            return encodeEliasDelta(numbers: numbers)
        case .eliasOmega:
            return encodeEliasOmega(numbers: numbers)
        case .fibonacci:
            return encodeFibonacci(numbers: numbers)
        }
    }
   
}

fileprivate func encodeEliasGamma(numbers: [UInt]) -> BitSet {
    var bitSet = BitSet()
    let binLeadingOne = UInt(kBinLeadingOne64)
    for n in numbers {
        // zero bitCount - 1 times, then actual n
        let bitCount = n.bitWidth - n.leadingZeroBitCount
        bitSet.add(repeating: false, count: bitCount - 1)
        for i in 0..<bitCount {
            let value = (n & (binLeadingOne >> UInt(n.leadingZeroBitCount + i))) != 0
            bitSet.add(value: value)
        }
    }
    
    return bitSet
}

fileprivate func encodeEliasDelta(numbers: [UInt]) -> BitSet {
    var bitSet = BitSet()
    let binLeadingOne = UInt(kBinLeadingOne64)
    for n in numbers {
        let nbitCount: UInt = UInt(n.bitWidth - n.leadingZeroBitCount)
        // elias gamma coding of n bit count
        let countBitCount = nbitCount.bitWidth - nbitCount.leadingZeroBitCount
        bitSet.add(repeating: false, count: countBitCount - 1)
        for i in 0..<countBitCount {
            let value = (nbitCount & (binLeadingOne >> UInt(nbitCount.leadingZeroBitCount + i))) != 0
            bitSet.add(value: value)
        }
        //  actual n coding without most significant bit
        for j in 1..<nbitCount {
            let value = (n & (binLeadingOne >> UInt(n.leadingZeroBitCount + Int(j)))) != 0
            bitSet.add(value: value)
        }
    }
    
    return bitSet
}

fileprivate func encodeEliasOmega(numbers: [UInt]) -> BitSet {
    var bitSet = BitSet()
    for n in numbers {
        var childBitSets: [BitSet] = []
        var k = n
        while k > 1 {
            var kBitSet = BitSet()
            kBitSet.add(integer: k)
            childBitSets.insert(kBitSet, at: 0)
            k = UInt(k.bitWidth - k.leadingZeroBitCount - 1) // k bit count - 1
        }
        
        for child in childBitSets {
            bitSet.add(bitSet: child)
        }
        bitSet.add(value: false)
    }
    
    return bitSet
}

fileprivate func encodeFibonacci(numbers: [UInt]) -> BitSet {
    var bitSet = BitSet()
    var k = 0, findex = 0
    for n in numbers {
        k = Int(n)
        var fibBitSet = BitSet()
        findex = largestOrEqualFib(k)
        fibBitSet.add(value: true)
        while k > 0 {
            fibBitSet.add(value: true)
            k = k - fib(findex)
            findex -= 1
            // fill with zeros for unused numbers
            while (findex > 0 && fib(findex) > k) {
                fibBitSet.add(value: false)
                findex -= 1
            }
        }
        fibBitSet = fibBitSet.reversed()
        bitSet.add(bitSet: fibBitSet)
    }
    
    return bitSet
}
