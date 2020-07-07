
import Foundation

public struct Spline<P: DataPoint> {
    
    /// To get the appropriate number of equations
    /// we need some kind of boundary condition
    /// - fixedTangentials: fixes the first derivative for both ends
    /// - smooth: fixes the second derivative to be zero at the ends
    /// - circular: derivative is the same at both ends
    public enum BoundaryCondition {
        case fixedTangentials(dAtStart: P, dAtEnd: P)
        case smooth
        case circular
    }
        
    /// Create a cubic piece wise spline based on the provided input
    /// - Parameters:
    ///   - values: The control values the spline will intercept
    ///   - arguments: optionally, the arguments at the control points t_0 .. t_n can be supplied,
    ///    by default they are 0 ... n
    ///   - boundaryCondition: the chosen `BoundaryCondition`
    public init(
        values: [P],
        arguments: [P.Scalar]? = nil,
        boundaryCondition: BoundaryCondition = .smooth
    ) {
        if let arguments = arguments, arguments.count != values.count {
            fatalError("Length of values and arguments arrays don't match, \(values.count) != \(arguments.count)")
        }
        
        let args = arguments ?? values.enumerated().map({ P.Scalar($0.0) })
        self.init(
            values: values,
            arguments: args,
            derivatives: Self.computeDerivatives(from: values),
            boundaryCondition: boundaryCondition
        )
    }
    
    /// In cases where y(t_n) and the derivative y'(t_n) is known for all points
    /// use this initializer
    /// - Parameter points: the control points
    /// - Parameter derivatives: f'(t) at the control points
    public init(
        values: [P],
        arguments: [P.Scalar],
        derivatives: [P],
        boundaryCondition: BoundaryCondition = .smooth
    ) {
        guard values.count == derivatives.count && values.count == arguments.count else {
            fatalError("The number of control points needs to be equal lentgh to the number of derivatives")
        }
        guard values.count >= 2 else {
            fatalError("Can't create piece wise spline with less then 2 control points")
        }
        self.controlPoints = arguments
        self.coefficients = Self.computeCoefficients(from: values, d: derivatives)
        self.boundary = boundaryCondition
    }
    
    /// Calculates the interpolation at a given argument
    /// - Parameter t: the argument provided
    /// - Returns: The interpolation calculated by finding the cubic spline segment and then calculating the cubic function of scaled t
    public func f(t: P.Scalar) -> P {
        guard t >= controlPoints[0] else {
            // extend constant function to the left
            switch boundary {
            case .circular:
                let negative = controlPoints[0] - t
                let factor = ceil(negative/length)
                let tNew = t + factor * length
                return f(t: tNew)
            case .fixedTangentials(let dAtStart, _):
                let negative = controlPoints[0] - t
                return coefficients[0].a + (negative * dAtStart)
            case .smooth:
                let len0 = (controlPoints[1] - controlPoints[0])
                let lambda = (t - controlPoints[0]) / len0
                return coefficients[0].f(t: lambda)
            }
        }

        guard let last = controlPoints.last else { return coefficients[0].a }
        guard t != last else {
            return coefficients.last!.f(t: 1)
        }
        guard t < last else {
            // extend constant function to the right
            // extend constant function to the left
            switch boundary {
            case .circular:
                let positive = t - last
                let factor = ceil(positive/length)
                let tNew = t - factor * length
                return f(t: tNew)
            case .fixedTangentials(_, let dAtEnd):
                let value = coefficients[coefficients.count - 1].f(t: 1)
                let positive = t - last
                return value + positive * dAtEnd
            case .smooth:
                let end = controlPoints.count - 1
                let len0 = (controlPoints[end] - controlPoints[end-1])
                let lambda = (t - controlPoints[end-1]) / len0
                return coefficients[controlPoints.count-2].f(t: lambda)
            }
        }
        
        // find t_n where t_n <= t < t_n+1
        let index = controlPoints.enumerated().first(where: { (offset, element) -> Bool in
            return element <= t && offset + 1 < controlPoints.count && t < controlPoints[offset+1]
        })?.offset ?? controlPoints.count - 1
        let lambda = (t - controlPoints[index])
            / (controlPoints[index + 1] - controlPoints[index])

        return coefficients[index].f(t: lambda)
    }
    
    private let boundary: BoundaryCondition
    private let controlPoints: [P.Scalar]
    private let coefficients: [CubicPoly]

    private var length: P.Scalar {
        guard let first = controlPoints.first, let last = controlPoints.last else {
            return 0
        }
        return last - first
    }
    
    struct CubicPoly {
        let a, b, c, d: P
    }
}

private extension Spline.CubicPoly {
    
    /// Piecewise function
    /// - Parameter t: input value between 0 and 1
    func f(t: P.Scalar) -> P {
        let t2 = t * t
        let linear: P = a + (t * b)
        let quadratic: P = (t2 * c)
        return linear + quadratic + (t2 * t * d)
    }
}
