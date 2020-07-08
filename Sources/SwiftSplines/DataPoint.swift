// Copyright (c) 2020 mathHeartCode UG(haftungsbeschränkt) <konrad@mathheartcode.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

// TODO: Distinguish between Float and Double Convertible types
// using NativeType and use SparseMatrix_Float and SparseMatrix_Double depending on the underlying ScalarType
public protocol DoubleConvertable {
    var asDouble: Double { get }
    init(_ double: Double)
}

extension Float: DoubleConvertable {
    public var asDouble: Double {
        return Double(self)
    }
}

extension Double: DoubleConvertable {
    public var asDouble: Double {
        return self
    }
}

public protocol DataPoint {
    associatedtype Scalar: FloatingPoint & DoubleConvertable
    
    static var scalarCount: Int { get }
    subscript(index: Int) -> Scalar { get set }
    
    static func * (left: Scalar, right: Self) -> Self
    static func + (left: Self, right: Self) -> Self
}

extension DataPoint {
    static func - (left: Self, right: Self) -> Self {
        return left + ( -1 * right)
    }
}
