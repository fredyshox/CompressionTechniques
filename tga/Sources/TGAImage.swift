//
//  TGAImage.swift
//  lista4
//
//  Created by Kacper Raczy on 04.12.2018.
//

import Foundation

fileprivate let kTGAHeaderLength = 18
fileprivate let kTGAFooterLength = 26
fileprivate let kTGABytesPerPixel = 3

public struct TGAImage {

    public enum TGAError: Error {
        case negativeIndex
        case indexOutOfBounds
    }

    public struct Color {
        public var red: UInt8
        public var green: UInt8
        public var blue: UInt8

        public static func make(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Color {
            return Color(red: red, green: green, blue: blue)
        }

        public static func +(lhs: Color, rhs: Color) -> Color {
            return Color.make(lhs.red &+ rhs.red, lhs.green &+ rhs.green, lhs.blue &+ rhs.blue)
        }

        public static func -(lhs: Color, rhs: Color) -> Color {
            return Color.make(lhs.red &- rhs.red, lhs.green &- rhs.green, lhs.blue &- rhs.blue)
        }

        public static func /(lhs: Color, rhs: UInt8) -> Color {
            return Color.make(lhs.red / rhs, lhs.green / rhs, lhs.blue / rhs)
        }
    }

    public private(set) var pixelValues: [Color]
    private let rawHeader: Data
    private let rawFooter: Data
    public let size: (width: UInt16, height: UInt16)

    public init(data: Data) {
        let header = data.prefix(kTGAHeaderLength)
        let imageSpec = header.advanced(by: 12)
        let width = UInt16(littleEndian: imageSpec.prefix(2).withUnsafeBytes({ $0.pointee }))
        let height = UInt16(littleEndian: imageSpec.dropFirst(2).prefix(2).withUnsafeBytes({ $0.pointee }))
        let imageData = data.advanced(by: kTGAHeaderLength).prefix(Int(width) * Int(height) * 3)
        self.pixelValues =
            imageData.chunked(into: 3).map { (channels) -> Color in
                return Color(red: channels[2], green: channels[1], blue: channels[0])
            }
        self.rawHeader = header
        self.rawFooter = data.suffix(kTGAFooterLength)
        self.size = (width: width, height: height)
    }

    public init(contentsOf path: String) throws {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        self.init(data: data)
    }

    public func get(_ row: Int) throws -> ArraySlice<Color> {
        guard row >= 0 else {
            throw TGAError.negativeIndex
        }

        if row >= size.height {
            throw TGAError.indexOutOfBounds
        } else {
            let startIdx = pixelValues.index(pixelValues.startIndex, offsetBy: row * Int(size.width))
            let endIdx = pixelValues.index(startIdx, offsetBy: Int(size.width))
            return pixelValues[startIdx..<endIdx]
        }
    }

    public func get(_ x: Int, _ y: Int) throws -> Color {
        guard x >= 0 && y >= 0 else {
            throw TGAError.negativeIndex
        }

        let idx = y * Int(size.width) + x
        if idx >= pixelValues.count {
            throw TGAError.indexOutOfBounds
        } else {
            return pixelValues[idx]
        }
    }

    mutating public func set(_ x: Int, _ y: Int, newValue: Color) throws {
        guard x >= 0 && y >= 0 else {
            throw TGAError.negativeIndex
        }

        let idx = y * Int(size.width) + x
        if idx >= pixelValues.count {
            throw TGAError.indexOutOfBounds
        } else {
            pixelValues[idx] = newValue
        }
    }

    public func data() -> Data {
        var result = Data()
        result.reserveCapacity(kTGAHeaderLength + kTGAFooterLength + width * height)
        result.append(rawHeader)
        for color in pixelValues {
            result.append(contentsOf: [color.blue, color.green, color.red])
        }
        result.append(rawFooter)

        return result
    }

    public var width: Int {
        return Int(size.width)
    }

    public var height: Int {
        return Int(size.height)
    }

}
