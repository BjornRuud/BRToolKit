//
// Copyright © 2021 BRToolKit. All rights reserved. 
//

import XCTest
@testable import BRToolKit

class ComparableClampedExtensionTests: XCTestCase {
    func testComparableClampedInt() throws {
        let range = 1...10

        let normal = 5.clamped(to: range)
        XCTAssertEqual(normal, 5)

        let tooLow = (-5).clamped(to: range)
        XCTAssertEqual(tooLow, range.lowerBound)

        let tooHigh = 15.clamped(to: range)
        XCTAssertEqual(tooHigh, range.upperBound)
    }

    func testComparableClampedDouble() throws {
        let range = 1.0...10.0

        let normal = 5.0.clamped(to: range)
        XCTAssertEqual(normal, 5.0)

        let tooLow = (-5.0).clamped(to: range)
        XCTAssertEqual(tooLow, range.lowerBound)

        let tooHigh = 15.0.clamped(to: range)
        XCTAssertEqual(tooHigh, range.upperBound)
    }
}

class ClampedPropertyWrapperTests: XCTestCase {
    struct TestIntStruct {
        @Clamped(range: 1...10)
        var normal: Int = 5

        @Clamped(range: 1...10)
        var tooHigh: Int = 15

        @Clamped(range: 1...10)
        var tooLow: Int = -5

        init() {
            XCTAssertEqual(normal, 5)
            XCTAssertEqual(tooHigh, 10)
            XCTAssertEqual(tooLow, 1)
        }

        mutating func reset(value: Int) {
            normal = value
            tooHigh = value
            tooLow = value
        }
    }

    struct TestDoubleStruct {
        @Clamped(range: 1.0 ... 10.0)
        var normal: Double = 5.0

        @Clamped(range: 1.0 ... 10.0)
        var tooHigh: Double = 15.0

        @Clamped(range: 1.0 ... 10.0)
        var tooLow: Double = -5.0

        init() {
            XCTAssertEqual(normal, 5.0)
            XCTAssertEqual(tooHigh, 10.0)
            XCTAssertEqual(tooLow, 1.0)
        }

        mutating func reset(value: Double) {
            normal = value
            tooHigh = value
            tooLow = value
        }
    }

    func testClampedPropertyWrapperInt() throws {
        var test = TestIntStruct()
        test.reset(value: 5)

        test.normal = 6
        XCTAssertEqual(test.normal, 6)
        test.tooHigh = 15
        XCTAssertEqual(test.tooHigh, 10)
        test.tooLow = -5
        XCTAssertEqual(test.tooLow, 1)
    }


    func testClampedPropertyWrapperDouble() throws {
        var test = TestDoubleStruct()
        test.reset(value: 5.0)

        test.normal = 6.0
        XCTAssertEqual(test.normal, 6.0)
        test.tooHigh = 15.0
        XCTAssertEqual(test.tooHigh, 10.0)
        test.tooLow = -5.0
        XCTAssertEqual(test.tooLow, 1.0)
    }
}
