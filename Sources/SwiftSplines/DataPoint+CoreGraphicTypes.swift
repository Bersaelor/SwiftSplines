//
//  File.swift
//  
//
//  Created by Konrad Feiler on 07.07.20.
//

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
