//
//  main.swift
//  LZW Compression decoder
//
//  Created by Kacper Raczy on 19.11.2018.
//

import Foundation
import Utility
import Basic
import LZW

func printErr(_ convertible: CustomStringConvertible = "") {
    fputs("\(convertible.description)\n", stderr)
}

let parser = ArgumentParser(usage: "<options> inputfile", overview: "LZW Encoder")
let universalCodingArg = parser.add(option: "--ucoding", shortName: "-u", kind: String.self, usage: "Universal coding option. Possible values: delta, gamma, omega, fibonacci. Delta is default value.")
let inputFileArg = parser.add(positional: "inputfile", kind: String.self, optional: false, usage: "File to be decompressed.")
var arguments: ArgumentParser.Result!
do {
    arguments = try parser.parse(Array(CommandLine.arguments.dropFirst()))
} catch let err {
    printErr(err.localizedDescription)
    exit(1)
}

var uCodingStr = arguments.get(universalCodingArg) ?? "delta"
var codingStrategy: UniversalDecodingStrategy!
switch uCodingStr {
case "delta":
    codingStrategy = .eliasDelta
case "gamma":
    codingStrategy = .eliasGamma
case "omega":
    codingStrategy = .eliasOmega
case "fibonacci":
    codingStrategy = .fibonacci
default:
    printErr("Incompatible universal coding argument.")
    parser.printUsage(on: stderrStream)
    exit(2)
}

let decoder = LZWDecoder()
decoder.dataDecodingStrategy = codingStrategy
let inputFile = arguments.get(inputFileArg)!
let url = URL(fileURLWithPath: inputFile)
let outputHandle = FileHandle.standardOutput
do {
    let inputData = try Data(contentsOf: url)
    let compressed = try decoder.decode(inputData)
    outputHandle.write(compressed)
} catch let err {
    printErr("Error: \(err.localizedDescription)")
    exit(3)
}
