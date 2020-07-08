
import Accelerate
import Foundation

extension Spline {
    
    static func computeCoefficients(from points: [P], d: [P]) -> [CubicPoly] {
        return points.indices.dropLast().map { (index) -> CubicPoly in
            let p0 = points[index]
            let p1 = points[index.advanced(by: 1)]
            let d0 = d[index]
            let d1 = d[index.advanced(by: 1)]
            return CubicPoly(p0: p0, p1: p1, d0: d0, d1: d1)
        }
    }
    
    static func computeDerivatives(
        from points: [P],
        boundaryCondition: BoundaryCondition
    ) -> [P] {
        var result = points
        var xValues: [Double] = Array(repeating: 0, count: points.count)
        let matrix = boundaryCondition.matrix(of: Int32(points.count))
        
        matrix.use { (matrix) in
            for dimension in 0 ..< P.scalarCount {
                xValues.withUnsafeMutableBufferPointer { xValuesPtr in
                    let x = DenseVector_Double(
                        count: Int32(points.count),
                        data: xValuesPtr.baseAddress!
                    )
                    let rightHandSide = DenseVector.cubicSpline(
                        points: points.map { $0[dimension] },
                        boundaryCondition: boundaryCondition,
                        dimension: dimension
                    )
                    rightHandSide.use { (rhs) in
                        let status = SparseSolve(
                            SparseConjugateGradient(),
                            matrix,
                            rhs,
                            x,
                            SparsePreconditionerDiagonal
                        )
                        if status != SparseIterativeConverged {
                            print("ERROR: Method failed to converge, error: ", status)
                        }
                    }
                }
                
                for value in xValues.enumerated() {
                    result[value.offset][dimension] = P.Scalar(value.element)
                }
            }
        }
        
        return result
    }
}

extension Spline.BoundaryCondition {
    
    func matrix(of size: Int32) -> SparseMatrix {
        switch self {
        case .circular:
            return SparseMatrix.cubicSplineCircularEndsTridiagonal(size: size)
        case .smooth:
            return SparseMatrix.cubicSplineSmoothEndsTridiagonal(size: size)
        case .fixedTangentials:
            return SparseMatrix.cubicSplineFixedEndsTridiagonal(size: size)
        }
    }
}
