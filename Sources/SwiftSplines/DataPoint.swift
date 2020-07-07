
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
