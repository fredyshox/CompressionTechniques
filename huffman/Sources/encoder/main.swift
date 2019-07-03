//
//  main.swift
//  huffman encoder
//
//  Created by Kacper Raczy on 06.11.2018.
//

import Foundation
import Huffman

if CommandLine.arguments.count < 2 {
    fputs("Usage: hencoder <input_file>\n", stderr)
    exit(1)
}

let path = CommandLine.arguments[1]
let url = URL(fileURLWithPath: path)
let outputHandle = FileHandle.standardOutput
do {
    let data = try Data(contentsOf: url)
    let encoder = HuffmanEncoder()
    let compressed = encoder.encode(data: data)
    fputs("Raw size: \(data.count) bytes, Compressed size: \(compressed.count)\n", stderr)
    fputs("Compression level: \(Double(data.count) / Double(compressed.count))\n", stderr)
    outputHandle.write(compressed)
} catch let err {
    fputs("Error: \(err.localizedDescription)\n", stderr)
    exit(2)
}
