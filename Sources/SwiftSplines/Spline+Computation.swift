
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
        let matrixCreator: (Int32, (SparseMatrix_Double) -> Void) -> Void
        if case .circular = boundaryCondition {
            matrixCreator = withCircularEndsTridiagonalMatrix
        } else {
            matrixCreator = withSmoothEndsTridiagonalMatrix
        }
        
        matrixCreator(Int32(points.count)) { matrix in
            for dimension in 0 ..< P.scalarCount {
                xValues.withUnsafeMutableBufferPointer { xValuesPtr in
                    let x = DenseVector_Double(
                        count: Int32(points.count),
                        data: xValuesPtr.baseAddress!
                    )
                    rightHandSize(points.map { $0[dimension] }, boundaryCondition: boundaryCondition) { rhs in
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
    
    // MARK: - Private implementation details
    
    /// https://mathworld.wolfram.com/CubicSpline.html
    /// cubic spline matrix with fixed derivatives at start and end
    /// 2 1   ... 0
    /// 1 4 1 ... 0
    /// 0 1 4 1.. 0
    /// ...     ...
    /// 0 ... 1 4 1
    /// 0 ...   1 2
    static func withSmoothEndsTridiagonalMatrix(
        size: Int32,
        calculate: (SparseMatrix_Double) -> Void
    ) {
        var columnStarts: [Int] = []
        var rowIndices: [Int32] = []
        var values: [Double] = []
        columnStarts.append(0)
        for column in 0..<size {
            switch column {
            case 0:
                values.append(contentsOf: [2, 1])
                rowIndices.append(contentsOf: [0, 1])
            case size-1:
                values.append(contentsOf: [1, 2])
                rowIndices.append(contentsOf: [column-1, column])
            default:
                values.append(contentsOf: [1, 4, 1])
                rowIndices.append(contentsOf: [column-1, column, column+1])
            }
            columnStarts.append(values.count)
        }
        
        columnStarts.withUnsafeMutableBufferPointer { columPtr in
            rowIndices.withUnsafeMutableBufferPointer { rowIndicesPtr in
                values.withUnsafeMutableBufferPointer { valuesPtr in
                    let matrix = SparseMatrix_Double(
                        structure: SparseMatrixStructure(
                            rowCount: size,
                            columnCount: size,
                            columnStarts: columPtr.baseAddress!,
                            rowIndices: rowIndicesPtr.baseAddress!,
                            attributes: SparseAttributes_t(
                                transpose: false,
                                triangle: SparseLowerTriangle,
                                kind: SparseSymmetric,
                                _reserved: 0,
                                _allocatedBySparse: false
                            ),
                            blockSize: 1
                        ),
                        data: valuesPtr.baseAddress!)
                    calculate(matrix)
                }
            }
        }
    }
    
    /// https://mathworld.wolfram.com/CubicSpline.html
    /// cubic spline matrix with fixed derivatives at start and end
    /// 4 1   ... 1
    /// 1 4 1 ... 0
    /// 0 1 4 1.. 0
    /// ...     ...
    /// 0 ... 1 4 1
    /// 1 ...   1 4
    static func withCircularEndsTridiagonalMatrix(
        size: Int32,
        calculate: (SparseMatrix_Double) -> Void
    ) {
        var columnStarts: [Int] = []
        var rowIndices: [Int32] = []
        var values: [Double] = []
        columnStarts.append(0)
        for column in 0..<size {
            switch column {
            case 0:
                values.append(contentsOf:     [4, 1, 1])
                rowIndices.append(contentsOf: [0, 1, size-1])
            case size-1:
                values.append(contentsOf:     [1, 1, 4])
                rowIndices.append(contentsOf: [0, column-1, column])
            default:
                values.append(contentsOf:     [1, 4, 1])
                rowIndices.append(contentsOf: [column-1, column, column+1])
            }
            columnStarts.append(values.count)
        }
        
        
        columnStarts.withUnsafeMutableBufferPointer { columPtr in
            rowIndices.withUnsafeMutableBufferPointer { rowIndicesPtr in
                values.withUnsafeMutableBufferPointer { valuesPtr in
                    let matrix = SparseMatrix_Double(
                        structure: SparseMatrixStructure(
                            rowCount: size,
                            columnCount: size,
                            columnStarts: columPtr.baseAddress!,
                            rowIndices: rowIndicesPtr.baseAddress!,
                            attributes: SparseAttributes_t(
                                transpose: false,
                                triangle: SparseLowerTriangle,
                                kind: SparseSymmetric,
                                _reserved: 0,
                                _allocatedBySparse: false
                            ),
                            blockSize: 1
                        ),
                        data: valuesPtr.baseAddress!)
                    calculate(matrix)
                }
            }
        }
    }
    
    static func rightHandSize(
        _ points: [P.Scalar],
        boundaryCondition: BoundaryCondition,
        calculate: (DenseVector_Double) -> Void
    ) {
        let y = points.map { $0.asDouble }
        var values = (0 ..< points.count).map { (index) -> Double in
            if index == 0 {
                if case .circular = boundaryCondition {
                    return 3 * (y[1] - y.last!)
                } else {
                    return 3 * (y[1] - y[0])
                }
            } else if index == points.count - 1 {
                if case .circular = boundaryCondition {
                    return 3 * (y[0] - y[index-1])
                } else {
                    return 3 * (y[index] - y[index-1])
                }
            } else {
                return 3 * (y[index+1] - y[index-1])
            }
        }
        values.withUnsafeMutableBufferPointer { valuePtr in
            let vector = DenseVector_Double(
                count: Int32(points.count),
                data: valuePtr.baseAddress!
            )
            calculate(vector)
        }
    }
}
