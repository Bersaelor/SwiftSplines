import XCTest
@testable import SwiftSplines

final class ConstantEdgeCase: XCTestCase {
    
    func testConstant_Smooth() {
        let args: [Double]   = [0, 1]
        let values: [Double] = [1, 1]
        let spline = Spline(arguments: args, values: values)

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }
    
    func testConstant_Three() {
        let args: [Double]   = [-1, 0, 1]
        let values: [Double] = [1, 1, 1]
        let spline = Spline(arguments: args, values: values)

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }

    func testConstant_NearlyConstant() {
        let args: [Double]   = [-3, -2, -1, -0.1, 0, 0.1, 1, 2, 3]
        let values: [Double] = [ 1,  1,  1,    1, 1.01, 1, 1, 1, 1]
        let spline = Spline(arguments: args, values: values, boundaryCondition: .circular)

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }

    func testConstant_Circular() {
        let args: [Double]   = [0, 1]
        let values: [Double] = [1, 1]
        let spline = Spline(arguments: args, values: values, boundaryCondition: .circular)

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }

    func testConstant_Parabola() {
        let args: [Double] = [-1, 0,  1]
        let values: [Double] = [1, 1, 1]
        let spline = Spline(arguments: args, values: values, boundaryCondition: .fixedTangentials(dAtStart: -1, dAtEnd: 1))

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }

    static var allTests = [
        ("testConstant_Smooth", testConstant_Smooth),
        ("testConstant_Three", testConstant_Three),
        ("testConstant_Parabola", testConstant_Parabola),
    ]
}
