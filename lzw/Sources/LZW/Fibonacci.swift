//
//  Fibonacci.swift
//  LZW
//
//  Created by Kacper Raczy on 20.11.2018.
//

import Foundation

fileprivate var cache: [Int: Int] = [0:1, 1:1]

internal func fib(_ n: Int) -> Int {
    if cache[n] != nil {
        return cache[n]!
    }
    
    let f1 = fib(n - 1)
    let f2 = fib(n - 2)
    cache[n - 1] = f1
    cache[n - 2] = f2
    cache[n] = f1 + f2
    return f1 + f2
}

// returns index of fibonacci number less or equal to n
internal func binetFormula(_ n: Int) -> Int {
    let x = log(sqrt(5.0) * Double(n)) / log((1.0 + sqrt(5.0)) / 2.0)
    return Int(x)
}

internal func largestOrEqualFib(_ n: Int) -> Int {
    var i = 1
    while fib(i) <= n {
        i += 1
    }
    
    return i - 1
}
