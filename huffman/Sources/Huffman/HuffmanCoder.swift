//
//  HuffmanCoder.swift
//  huffman
//
//  Created by Kacper Raczy on 06.11.2018.
//

import Foundation

class HuffmanNode {
    let frequency: Int
    let value: UInt8?
    var child_0: HuffmanNode?
    var child_1: HuffmanNode?

    init(frequency: Int, value: UInt8?, child_0: HuffmanNode? = nil, child_1: HuffmanNode? = nil) {
        self.frequency = frequency
        self.value = value
        self.child_0 = child_0
        self.child_1 = child_1
    }

    var isLeaf: Bool {
        return child_0 == nil && child_1 == nil
    }
}

/**
 Abstract class which contains common huffman operations
 */
public class HuffmanCoder {
    func generateSymbolMap(node: HuffmanNode) -> [UInt8: BinarySymbol] {
        var symbolMap: [UInt8: BinarySymbol] = [:]
        generateSymbolMap(node: node, dict: &symbolMap)
        return symbolMap
    }

    func generateSymbolMap(node: HuffmanNode?, dict: inout [UInt8: BinarySymbol], length: UInt8 = 0, value: UInt64 = 0) {
        guard let node = node else {
            return
        }

        if node.isLeaf && node.value != nil {
            dict[node.value!] = BinarySymbol(value: value, length: length)
            return
        }
        generateSymbolMap(node: node.child_0, dict: &dict, length: length + 1, value: value)
        generateSymbolMap(node: node.child_1, dict: &dict, length: length + 1, value: value | (kBinLeadingOne >> length))
    }

    func printCodes(_ node: HuffmanNode?, s: String = "") {
        guard let node = node else {
            return
        }

        if node.isLeaf && node.value != nil {
            printErr("\(String(node.value!, radix:16)) : \(s)")
            return
        }

        printCodes(node.child_0, s: s + "0")
        printCodes(node.child_1, s: s + "1")
    }

    func generateHuffmanTree(frequencyArr: [Int]) -> HuffmanNode {
        var nodeQueue: PriorityQueue<HuffmanNode> = PriorityQueue(sort: { $0.frequency < $1.frequency })
        for (byte, frequency) in frequencyArr.enumerated() where frequency != 0 {
            nodeQueue.enqueue(HuffmanNode(frequency: frequency, value: UInt8(byte)))
        }

        while nodeQueue.count > 1 {
            let nextTree1 = nodeQueue.dequeue()!
            let nextTree2 = nodeQueue.dequeue()!
            let parentFrequency = nextTree1.frequency + nextTree2.frequency
            let parent = HuffmanNode(frequency: parentFrequency, value: nil, child_0: nextTree1, child_1: nextTree2)
            nodeQueue.enqueue(parent)
        }

        let node = nodeQueue.dequeue()!
        return node
    }

    func byteFrequency(bytes: [UInt8]) -> [Int] {
        var freqArr = [Int](repeating: 0, count: 256)
        for byte in bytes {
            freqArr[Int(byte)] += 1
        }

        return freqArr
    }

    public func entropy(freqMap: [UInt8: Int], dataLength: Int) -> Double {
        var result = 0.0
        for (_, value) in freqMap {
            let prob = Double(value) / Double(dataLength)
            result += prob * -1 * log2(prob)
        }

        return result
    }
}
