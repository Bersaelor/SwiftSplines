import XCTest
@testable import SwiftSplines

final class SwiftSplinesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftSplines().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
