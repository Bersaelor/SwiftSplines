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

struct DenseVector {
    let values: [Double]

    func use(calculate: (DenseVector_Double) -> Void) {
        var mutableValues = self.values
        mutableValues.withUnsafeMutableBufferPointer { valuePtr in
            let vector = DenseVector_Double(
                count: Int32(values.count),
                data: valuePtr.baseAddress!
            )
            calculate(vector)
        }
    }
}

extension DenseVector {
    
    static func cubicSpline<P: DataPoint>(
        points: [P.Scalar],
        boundaryCondition: Spline<P>.BoundaryCondition,
        dimension: Int
    ) -> DenseVector {
        let y = points.map { $0.asDouble }
        let values = (0 ..< points.count).map { (index) -> Double in
            if index == 0 {
                switch boundaryCondition {
                case .circular:
                    return 3 * (y[1] - y.last!)
                case .fixedTangentials(let dAtStart, _):
                    return dAtStart[dimension].asDouble
                case .smooth:
                    return 3 * (y[1] - y[0])
                }
            } else if index == points.count - 1 {
                switch boundaryCondition {
                case .circular:
                    return 3 * (y[0] - y[index-1])
                case .fixedTangentials(_, let dAtEnd):
                    return dAtEnd[dimension].asDouble
                case .smooth:
                    return 3 * (y[index] - y[index-1])
                }
            } else {
                return 3 * (y[index+1] - y[index-1])
            }
        }
        return DenseVector(values: values)
    }
    
}
