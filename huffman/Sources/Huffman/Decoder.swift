//
//  Decoder.swift
//  huffman
//
//  Created by Kacper Raczy on 06.11.2018.
//

import Foundation

struct HuffmanHeader: CustomStringConvertible {
    var symbolCount: UInt16 = 0
    var byteFrequency: [Int] = [Int](repeating: 0, count: 256)
    var paddingCount: UInt8 = 0

    var byteLength: Int {
        return 3 + Int(symbolCount) * 9
    }

    var description: String {
        return "symbolCount: \(symbolCount), byteFrequency: \(byteFrequency), paddingCount: \(paddingCount)"
    }
}


public class HuffmanDecoder: HuffmanCoder {

    public enum DecoderError: Error {
        case headerIncomplete
        case dataIncomplete
        case dataCorrupted
    }

    public override init() { super.init() }

    public func decode(data: Data) throws -> Data {
        let header = try decodeHeader(data: data)
        let remainingBytes = data[header.byteLength...]
        let binaryQueue = BinaryQueue(bytes: [UInt8](remainingBytes), padding: Int(header.paddingCount))
        let remainingBits = binaryQueue.length
        let huffmanTree = generateHuffmanTree(frequencyArr: header.byteFrequency)
        var currentNode: HuffmanNode? = huffmanTree
        var outputBuffer = Data()
        for i in 0..<remainingBits {
            if binaryQueue.bit(at: i) {
                currentNode = currentNode?.child_1
            } else {
                currentNode = currentNode?.child_0
            }

            guard let node = currentNode else {
                throw DecoderError.dataCorrupted
            }

            if node.isLeaf {
                guard let value = node.value else {
                    throw DecoderError.dataCorrupted
                }
                outputBuffer.append(value)
                currentNode = huffmanTree
            }
        }

        return outputBuffer
    }

    /**
     Huffman header described in Encoder
    */
    private func decodeHeader(data: Data) throws -> HuffmanHeader {
        guard data.count > 2 else {
            throw DecoderError.dataIncomplete
        }

        var header = HuffmanHeader()
        var symbolCount = UInt16(littleEndian: data.withUnsafeBytes({ $0.pointee }))
        var iterator = data.advanced(by: 2).makeIterator()
        header.symbolCount = symbolCount
        let bytesPerSymbol = 9
        while symbolCount > 0 {
            var bytes = [UInt8](repeating: 0x00, count: bytesPerSymbol)
            for i in 0..<bytesPerSymbol {
                guard let byte = iterator.next() else {
                    throw DecoderError.headerIncomplete
                }

                bytes[i] = byte
            }

            let byte = bytes[0]
            let value = Int(littleEndian: Data(bytes[1...8]).withUnsafeBytes({ $0.pointee }))
            header.byteFrequency[Int(byte)] = value
            symbolCount -= 1
        }

        guard let padding = iterator.next() else {
            throw DecoderError.headerIncomplete
        }
        header.paddingCount = padding

        return header
    }

}
