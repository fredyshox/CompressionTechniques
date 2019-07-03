//
//  Filter.swift
//  lista6
//
//  Created by Kacper Raczy on 22.01.2019.
//

import Foundation
import TGAImage

protocol Filter {
    func apply(image: inout TGAImage)
}
