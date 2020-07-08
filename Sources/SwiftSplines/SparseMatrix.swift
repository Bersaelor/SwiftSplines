
import Accelerate
import Foundation

struct SparseMatrix {

    let size: Int32
    let isSymmetric: Bool
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
                            attributes: sparseAttributes,
                            blockSize: 1
                        ),
                        data: valuesPtr.baseAddress!)
                    calculate(matrix)
                }
            }
        }
    }
    
    private var sparseAttributes: SparseAttributes_t {
        if isSymmetric {
            return SparseAttributes_t(
                transpose: false,
                triangle: SparseLowerTriangle,
                kind: SparseSymmetric,
                _reserved: 0,
                _allocatedBySparse: false
            )
        } else {
            return SparseAttributes_t()
        }
    }
    
    /// Only for debug purposes, don't use this method in production
    func createDense() -> [[Double]] {
        var result = (0 ..< size).map { (row) -> [Double] in
            return Array(repeating: Double(0), count: Int(size))
        }
        
        var currentColumn = 0
        for pair in values.enumerated() {
            let row = rowIndices[pair.offset]
            
            if pair.offset >= columnStarts[currentColumn+1] {
                currentColumn += 1
            }
            guard row < size && currentColumn < size else {
                print("Warning: (\(row),\(currentColumn) is not in \(size)x\(size)")
                continue
            }
            result[Int(row)][currentColumn] = pair.element
        }
        
        return result
    }
}

extension SparseMatrix : CustomDebugStringConvertible {
    
    var debugDescription: String {
        var result = String(repeating: "▁▁", count: Int(size)) + "\n"
        
        let denseMatrix = createDense()
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 3
        
        for row in (0 ..< size) {
            let entries = denseMatrix[Int(row)].map { formatter.string(for: $0) ?? "?"}
            let rowString = entries.joined(separator: " ")
            result.append(rowString + "\n")
            
        }
        
        result.append(String(repeating: "▔▔", count: Int(size)) + "\n")

        return result
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
            isSymmetric: true,
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
            isSymmetric: true,
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
                values.append(contentsOf:     [1, 4])
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
            isSymmetric: false,
            columnStarts: columnStarts,
            rowIndices: rowIndices,
            values: values
        )
    }
}
