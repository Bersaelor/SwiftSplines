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
    
    func testLinear() {
        let points: [Double] = [0, 1, 2, 3, 4, 5]
        let spline = Spline(points: points)
        
        for value in points.enumerated() {
            let t = Double(value.offset)
            let result = spline.f(t: t)
            XCTAssertEqual(points[value.offset], result, accuracy: 0.0001)
        }
    }

    static var allTests = [
        ("testLine", testLine),
    ]
}
