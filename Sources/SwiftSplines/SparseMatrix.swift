
import Accelerate
import Foundation

struct SparseMatrix {

    let size: Int32
    let columnStarts: [Int]
    let rowIndices: [Int32]
    let values: [Double]

    func use(calculate: (SparseMatrix_Double) -> Void) {
        var columnStarts = self.columnStarts
        var rowIndices = self.rowIndices
        var values = self.values

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
}

extension SparseMatrix {
    
    /// https://mathworld.wolfram.com/CubicSpline.html
    /// cubic spline matrix with fixed derivatives at start and end
    /// 2 1   ... 0
    /// 1 4 1 ... 0
    /// 0 1 4 1.. 0
    /// ...     ...
    /// 0 ... 1 4 1
    /// 0 ...   1 2
    static func cubicSplineSmoothEndsTridiagonal(size: Int32) -> SparseMatrix {
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
        
        return SparseMatrix(
            size: size,
            columnStarts: columnStarts,
            rowIndices: rowIndices,
            values: values
        )
    }
    
    /// https://mathworld.wolfram.com/CubicSpline.html
    /// cubic spline matrix with fixed derivatives at start and end
    /// 4 1   ... 1
    /// 1 4 1 ... 0
    /// 0 1 4 1.. 0
    /// ...     ...
    /// 0 ... 1 4 1
    /// 1 ...   1 4
    static func cubicSplineCircularEndsTridiagonal(size: Int32) -> SparseMatrix {
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
        
        return SparseMatrix(
            size: size,
            columnStarts: columnStarts,
            rowIndices: rowIndices,
            values: values
        )
    }
    
    static func cubicSplineFixedEndsTridiagonal(size: Int32) -> SparseMatrix {
        var columnStarts: [Int] = []
        var rowIndices: [Int32] = []
        var values: [Double] = []
        columnStarts.append(0)
        for column in 0..<size {
            switch column {
            case 0:
                values.append(contentsOf:     [1, 1])
                rowIndices.append(contentsOf: [0, 1])
            case 1 where size == 3:
                values.append(contentsOf:     [4])
                rowIndices.append(contentsOf: [1])
            case 1 where size > 3:
                values.append(contentsOf:     [4, 1])
                rowIndices.append(contentsOf: [1, 2])
            case size-2 where size > 3:
                values.append(contentsOf:     [4, 0])
                rowIndices.append(contentsOf: [column-1, column])
            case size-1:
                values.append(contentsOf:     [1, 1])
                rowIndices.append(contentsOf: [column-1, column])
            default:
                values.append(contentsOf:     [1, 4, 1])
                rowIndices.append(contentsOf: [column-1, column, column+1])
            }
            columnStarts.append(values.count)
        }
        
        return SparseMatrix(
            size: size,
            columnStarts: columnStarts,
            rowIndices: rowIndices,
            values: values
        )
    }
}


