import XCTest
@testable import SwiftSplines

final class ConstantEdgeCase: XCTestCase {
    
    func testConstant_Smooth() {
        let values: [Double] = [0,  1]
        let args: [Double]   = [1, 1]
        let spline = Spline(arguments: args, values: values)

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }

    func testConstant_Circular() {
        let values: [Double] = [0,  2]
        let args: [Double]   = [0.1, 0.1]
        let spline = Spline(arguments: args, values: values, boundaryCondition: .circular)

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }

    func testConstant_ConstantBoundary() {
        let values: [Double] = [0,  2]
        let args: [Double]   = [0.1, 0.1]
        let spline = Spline(arguments: args, values: values, boundaryCondition: .fixedTangentials(dAtStart: 0, dAtEnd: 0))

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }

    func testConstant_Parabola() {
        let values: [Double] = [-1,  1]
        let args: [Double]   = [1, 1]
        let spline = Spline(arguments: args, values: values, boundaryCondition: .fixedTangentials(dAtStart: -1, dAtEnd: 1))

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }


    static var allTests = [
        ("testConstant_Smooth", testConstant_Smooth),
        ("testConstant_Circular", testConstant_Circular),
        ("testConstant_ConstantBoundary", testConstant_ConstantBoundary),
        ("testConstant_Parabola", testConstant_Parabola),
    ]
}
