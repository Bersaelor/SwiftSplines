import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BasicTests.allTests),
        testCase(ConstantEdgeCase.allTests),
    ]
}
#endif
