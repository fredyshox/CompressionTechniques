import XCTest
import class Foundation.Bundle
import Foundation
import LZW

final class lzwTests: XCTestCase {
    let input: [UInt] = [1,2,3,4,5,255,266,277,288, 40,3,1]
    
    func testLZWCoding() throws {
        let encoder = LZWEncoder()
        let decoder = LZWDecoder()
        let input = "wabba-wabba-wabba-woo-woo-woo"
        let inputData = input.data(using: .utf8)!
        let encoded = encoder.encode(inputData)
        print("enc \(encoded.count)")
        let decoded = try decoder.decode(encoded)
        print("dec \(decoded.count)")
        let decodedStr = String(bytes: [UInt8](decoded), encoding: .utf8)
        XCTAssertEqual(input, decodedStr)
    }
    
    func testEliasGamma() throws {
        let encodingStrategy = UniversalEncodingStrategy.eliasGamma
        let decodingStrategy = UniversalDecodingStrategy.eliasGamma
        try testUniversalCoding(encodingStrategy, decodingStrategy)
    }
    
    func testEliasDelta() throws {
        let encodingStrategy = UniversalEncodingStrategy.eliasDelta
        let decodingStrategy = UniversalDecodingStrategy.eliasDelta
        try testUniversalCoding(encodingStrategy, decodingStrategy)
    }
    
    func testEliasOmega() throws {
        let encodingStrategy = UniversalEncodingStrategy.eliasOmega
        let decodingStrategy = UniversalDecodingStrategy.eliasOmega
        try testUniversalCoding(encodingStrategy, decodingStrategy)
    }
    
    func testFibonacci() throws {
        let encodingStrategy = UniversalEncodingStrategy.fibonacci
        let decodingStrategy = UniversalDecodingStrategy.fibonacci
        try testUniversalCoding(encodingStrategy, decodingStrategy)
    }
    
    func testUniversalCoding(_ encodingStrategy: UniversalEncodingStrategy, _ decodingStrategy: UniversalDecodingStrategy) throws {
        let bs = encodingStrategy.encode(numbers: input)
        print("encoded bytes \(bs.bytes.count)")
        printEncoded(bs)
        let output = try decodingStrategy.decode(bitSet: bs)
        print("decoded numbers: \(output)")
        
        XCTAssertEqual(input, output)
    }
    
    func printEncoded(_ bs: BitSet) {
        for i in 0..<bs.bytes.count {
            let byte = bs.bytes[i]
            let prefix = String([Character](repeating: "0", count: byte.leadingZeroBitCount))
            let suffix = byte == 0 ? "" : String(byte, radix: 2)
            print("\(prefix)\(suffix)")
        }
    }

    static var allTests = [
        ("testEliasGamma", testEliasGamma),
        ("testEliasDelta", testEliasDelta),
        ("testEliasOmega", testEliasOmega),
        ("testLZWCoding", testLZWCoding)
    ]
}
