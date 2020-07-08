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

import CoreGraphics

extension CGFloat: DoubleConvertable {
    public var asDouble: Double {
        return Double(self)
    }
}

extension CGPoint: DataPoint {
    public static var scalarCount: Int { return 2 }

    public subscript(index: Int) -> CGFloat {
        get {
            index == 0 ? self.x : self.y
        }
        set(newValue) {
            if index == 0 {
                x = newValue
            } else {
                y = newValue
            }
        }
    }
    
    public static func * (left: Self.Scalar, right: Self) -> Self {
        return CGPoint(x: left * right.x, y: left * right.y)
    }
    
    public static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(
            x: left.x + right.x,
            y: left.y + right.y
        )
    }
}

extension CGVector: DataPoint {
    public static var scalarCount: Int { return 2 }

    public subscript(index: Int) -> CGFloat {
        get {
            index == 0 ? self.dx : self.dy
        }
        set(newValue) {
            if index == 0 {
                dx = newValue
            } else {
                dy = newValue
            }
        }
    }
    
    public static func * (left: Self.Scalar, right: Self) -> Self {
        return CGVector(dx: left * right.dx, dy: left * right.dy)
    }
    
    public static func + (left: Self, right: Self) -> Self {
        return CGVector(
            dx: left.dx + right.dx,
            dy: left.dy + right.dy
        )
    }
}
