
import Foundation

public protocol DataPoint {
    associatedtype Scalar: SIMDScalar & FloatingPoint
    
    var scalarCount: Int { get }
    subscript(index: Int) -> Self.Scalar { get set }
    
    static func * (left: Self.Scalar, right: Self) -> Self
    static func + (left: Self, right: Self) -> Self
}

extension DataPoint {
    static func - (left: Self, right: Self) -> Self {
        return left + ( -1 * right)
    }
}


extension FloatingPoint {
    
    public var scalarCount: Int { return 1 }

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
