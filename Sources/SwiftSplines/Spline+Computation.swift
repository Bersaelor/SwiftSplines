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
                    let rightHandSide = DenseVector.cubicSpline(
                        points: points.map { $0[dimension] },
                        boundaryCondition: boundaryCondition,
                        dimension: dimension
                    )
                    
                    guard !rightHandSide.isZero else { return }
                    
                    let x = DenseVector_Double(
                        count: Int32(points.count),
                        data: xValuesPtr.baseAddress!
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
