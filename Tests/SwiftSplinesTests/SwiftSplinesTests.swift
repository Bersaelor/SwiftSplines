import XCTest
@testable import SwiftSplines

final class SwiftSplinesTests: XCTestCase {
    func testLine() {
        let points: [Double] = [0, 1, 2, 3, 4, 5]
        let derivatives: [Double] = Array(repeating: 1, count: points.count)
        let arguments = points.enumerated().map({ Double($0.0) })
        let spline = Spline(values: points, arguments: arguments, derivatives: derivatives)
        
        for value in points.enumerated() {
            let t = Double(value.offset)
            let result = spline.f(t: t)
            XCTAssertEqual(points[value.offset], result, accuracy: 0.0001)
        }
    }
    
    func testCoefficientCalculation_Linear() {
        let values: [Double] = [0, 1, 2, 3, 4, 5]
        let spline = Spline(values: values)
        
        for value in values.enumerated() {
            let t = Double(value.offset)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }

    func testCoefficientCalculation_Quadratic() {
        let values: [Double] = [-1, 0, 1, 2, 4, 8, 16]
        let spline = Spline(values: values)
        
        for value in values.enumerated() {
            let t = Double(value.offset)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
            let shortBefore = Double(value.offset) - 100 * Double.ulpOfOne
            XCTAssertEqual(values[value.offset], spline.f(t: shortBefore), accuracy: 0.0001)
        }
    }

    func testCoefficientCalculation_UpDown() {
        let values: [Double] = [0, -1, 2, -3, 4, -5]
        let spline = Spline(values: values)
        
        for value in values.enumerated() {
            let t = Double(value.offset)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
            let shortBefore = Double(value.offset) - 100 * Double.ulpOfOne
            XCTAssertEqual(values[value.offset], spline.f(t: shortBefore), accuracy: 0.0001)
        }
    }
    
    func testUnequallySpacedArguments() {
        let values: [Double] = [0,  -1,   2,  -3, 4, -5]
        let args: [Double]   = [0, 0.1, 0.5, 1.5, 3, 10]
        let spline = Spline(values: values, arguments: args)

        for value in args.enumerated() {
            let t = Double(value.element)
            let result = spline.f(t: t)
            XCTAssertEqual(values[value.offset], result, accuracy: 0.0001)
        }
    }
    
    static var allTests = [
        ("testLine", testLine),
        ("testCoefficientCalculation_Linear", testCoefficientCalculation_Linear),
        ("testCoefficientCalculation_Quadratic", testCoefficientCalculation_Quadratic),
        ("testCoefficientCalculation_UpDown", testCoefficientCalculation_UpDown),
        ("testUnequallySpacedArguments", testUnequallySpacedArguments),
    ]
}
