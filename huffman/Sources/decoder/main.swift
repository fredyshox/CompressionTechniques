//
//  main.swift
//  decoder
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
    let decoder = HuffmanDecoder()
    let decompressed = try decoder.decode(data: data)
    outputHandle.write(decompressed)
} catch let err {
    fputs("Error: \(err.localizedDescription)\n", stderr)
    exit(2)
}
