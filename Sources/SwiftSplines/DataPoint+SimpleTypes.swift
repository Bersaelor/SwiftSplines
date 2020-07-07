//
//  File.swift
//  
//
//  Created by Konrad Feiler on 07.07.20.
//

import Foundation

extension FloatingPoint {
    
    public static var scalarCount: Int { return 1 }

    public subscript(index: Int) -> Self {
        get {
            self
        }
        set(newValue) {
            self = newValue
        }
    }
}

extension Float: DataPoint { }
extension Double: DataPoint { }
