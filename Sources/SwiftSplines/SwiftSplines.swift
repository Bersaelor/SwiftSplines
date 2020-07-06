
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
    
    private let boundary: BoundaryCondition
    private let controlPoints: [(t: P.Scalar, p: P)]
    private let coefficients: [CubicPoly]

    public init(
        points: [P],
        boundaryCondition: BoundaryCondition = .smooth
    ) {
        let controlPoints = points.enumerated().map({ (offset, element) in
            return (P.Scalar(offset), element)
        })
        let derivatives = Self.computeDerivatives(from: points)
        self.init(points: controlPoints, derivatives: derivatives, boundaryCondition: boundaryCondition)
    }
    
    /// In cases where y(t_n) and the derivative y'(t_n) is known for all points
    /// use this initializer
    /// - Parameter points: the control points
    /// - Parameter derivatives: f'(t) at the control points
    public init(
        points: [(t: P.Scalar, p: P)],
        derivatives: [P],
        boundaryCondition: BoundaryCondition = .smooth
    ) {
        guard points.count == derivatives.count else {
            fatalError("The number of control points needs to be equal lentgh to the number of derivatives")
        }
        guard points.count >= 2 else {
            fatalError("Can't create piece wise spline with less then 2 control points")
        }
        self.controlPoints = points
        self.coefficients = Self.computeCoefficients(
            from: self.controlPoints.map({ $0.p }),
            d: derivatives
        )
        self.boundary = boundaryCondition
    }

    public func f(t: P.Scalar) -> P {
        guard t > controlPoints[0].t else {
            // extend constant function to the left
            switch boundary {
            case .circular:
                let negative = controlPoints[0].t - t
                let factor = ceil(-negative/length)
                let tNew = t + factor * length
                return f(t: tNew)
            case .fixedTangentials(let dAtStart, _):
                let negative = controlPoints[0].t - t
                return controlPoints[0].p + (negative * dAtStart)
            case .smooth:
                return controlPoints[0].p
            }
        }

        guard let last = controlPoints.last else { return controlPoints[0].p }
        guard t < last.t else {
            // extend constant function to the right
            // extend constant function to the left
            switch boundary {
            case .circular:
                let positive = t - last.t
                let factor = ceil(positive/length)
                let tNew = t - factor * length
                return f(t: tNew)
            case .fixedTangentials(_, let dAtEnd):
                let positive = t - last.t
                return last.p + positive * dAtEnd
            case .smooth:
                return last.p
            }
        }
        let index = controlPoints.firstIndex(where: { $0.t < t })!
        let lambda = (t - controlPoints[index].t)/(controlPoints[index.advanced(by: 1)].t - controlPoints[index].t)
        return coefficients[index].f(t: lambda)
    }
    
    private var length: P.Scalar {
        guard let first = controlPoints.first, let last = controlPoints.last else {
            return 0
        }
        return last.t - first.t
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
