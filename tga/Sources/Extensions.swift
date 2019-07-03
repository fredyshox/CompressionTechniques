//
//  Utility.swift
//  lista4
//
//  Created by Kacper Raczy on 11.12.2018.
//

import Foundation

extension Array {
    func get(_ index: Index) -> Element? {
        if index < startIndex || index > endIndex {
            return nil
        }
        
        return self[index]
    }
}

extension Collection {
    func chunked(into size: Int) -> [[Self.Element]] {
        return stride(from: 0, to: count, by: size).map {
            let idx = index(startIndex, offsetBy: $0)
            let nextInx = index(idx, offsetBy: size)
            return Array(self[idx ..< Swift.min(nextInx, endIndex)])
        }
    }
}
