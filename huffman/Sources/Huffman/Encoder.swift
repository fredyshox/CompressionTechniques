//
//  Encoder.swift
//  huffman
//
//  Created by Kacper Raczy on 06.11.2018.
//

import Foundation

public class HuffmanEncoder: HuffmanCoder {

    public override init() { super.init() }

    public func encode(data: Data) -> Data {
        let freqArr = byteFrequency(bytes: [UInt8](data))
        let huffmanTree = generateHuffmanTree(frequencyArr: freqArr)
        let symbolMap = generateSymbolMap(node: huffmanTree)
        var iterator = data.makeIterator()
        var container = BinaryQueue()
        while let byte = iterator.next() {
            let symbol = symbolMap[byte]!
            container.nextBits(symbol)
        }
        var compressed = Data()
        let header = createHeader(frequencyArr: freqArr, padding: container.padding)
        compressed.append(header)
        compressed.append(contentsOf: container.bytes)

        return compressed
    }

    /** header:
     *  - total number of chars - 1 byte
     *  - char (1 byte) : frequency (8 bytes)
     *  - (n times)
     *  - padding length p (1 byte) - padding bytes (p bytes) at the end of file
     */
    private func createHeader(frequencyArr: [Int], padding: Int) -> Data {
        var headerData = Data()
        var symbolCount = frequencyArr.filter({ $0 != 0 }).count
        let symbolData = Data(bytes: &symbolCount, count: MemoryLayout<UInt16>.size)
        headerData.append(symbolData)
        for (byte, freq) in frequencyArr.enumerated() where freq != 0 {
            headerData.append(UInt8(byte))
            var freqMutable = freq
            let symbolData = Data(bytes: &freqMutable, count: MemoryLayout<Int>.size)
            headerData.append(symbolData)
        }
        headerData.append(UInt8(padding))

        return headerData
    }

    /**
     * - total tree bits
     * - tree bits
     * - tree padding
     * - padding length for data
    */
    private func createHeader2(huffmanTree: HuffmanNode, padding: Int) -> Data {
        var headerData = Data()
        var bitSet = BinaryQueue()
        encodeTree(huffmanTree, bitSet: &bitSet)
        var treeBitCount = UInt32(bitSet.length)
        let treeBitCountData = Data(bytes: &treeBitCount, count: MemoryLayout<UInt32>.size)

        headerData.append(treeBitCountData)
        headerData.append(bitSet.data)
        headerData.append(UInt8(padding))
        return headerData
    }

    private func encodeTree(_ node: HuffmanNode?, bitSet: inout BinaryQueue) {
        guard let node = node else {
            return
        }

        if node.isLeaf && node.value != nil {
            bitSet.nextBit(true)
            bitSet.nextBits(node.value!)
        } else {
            bitSet.nextBit(false)
            encodeTree(node.child_0, bitSet: &bitSet)
            encodeTree(node.child_1, bitSet: &bitSet)
        }
    }

    private func averageCodeLength(frequencyMap: [UInt8: Int], symbolMap: [UInt8: BinarySymbol], dataLength: Int) -> Double {
        var result = 0.0
        for (byte, freq) in frequencyMap {
            result += Double(freq) * Double(symbolMap[byte]!.length)
        }

        return result / Double(dataLength)
    }

}
