import XCTest
@testable import SwiftSplines

final class SwiftSplinesTests: XCTestCase {
    func testLine() {
        let points: [Double] = [0, 1, 2, 3, 4, 5]
        let derivatives: [Double] = Array(repeating: 1, count: points.count)
        let controlPoints = points.enumerated().map({ (offset, element) in
            return (Double(offset), element)
        })
        let spline = Spline(points: controlPoints, derivatives: derivatives)
        
        for value in points.enumerated() {
            let t = Double(value.offset)
            let result = spline.f(t: t)
            XCTAssertEqual(points[value.offset], result, accuracy: 0.0001)
        }
    }
    
    func testCoefficientCalculation_Linear() {
        let points: [Double] = [0, 1, 2, 3, 4, 5]
        let spline = Spline(points: points)
        
        for value in points.enumerated() {
            let t = Double(value.offset)
            let result = spline.f(t: t)
            XCTAssertEqual(points[value.offset], result, accuracy: 0.0001)
        }
    }

    func testCoefficientCalculation_Quadratic() {
        let points: [Double] = [-1, 0, 1, 2, 4, 8, 16]
        let spline = Spline(points: points)
        
        for value in points.enumerated() {
            let t = Double(value.offset)
            let result = spline.f(t: t)
            XCTAssertEqual(points[value.offset], result, accuracy: 0.0001)
        }
    }

    func testCoefficientCalculation_UpDown() {
        let points: [Double] = [0, -1, 2, -3, 4, -5]
        let spline = Spline(points: points)
        
        for value in points.enumerated() {
            let t = Double(value.offset)
            let result = spline.f(t: t)
            XCTAssertEqual(points[value.offset], result, accuracy: 0.0001)
        }
    }
    
    static var allTests = [
        ("testLine", testLine),
        ("testCoefficientCalculation_Linear", testCoefficientCalculation_Linear),
        ("testCoefficientCalculation_Quadratic", testCoefficientCalculation_Quadratic),
        ("testCoefficientCalculation_UpDown", testCoefficientCalculation_UpDown),
    ]
}
