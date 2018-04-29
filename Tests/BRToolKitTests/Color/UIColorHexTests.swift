//
//  UIColorHexTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 08/04/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation
import XCTest
@testable import BRToolKit

class UIColorHexTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testIntValue() {
        let reference: UInt32 = 0xffffff
        let white = UIColor.white
        let whiteInt = white.rgbInt32()
        XCTAssertEqual(reference, whiteInt)

        let referenceAlpha: UInt32 = 0xffffffff
        let whiteIntAlpha = white.rgbInt32(withAlpha: true)
        XCTAssertEqual(referenceAlpha, whiteIntAlpha)

        let refGrey50: UInt32 = 0x333333
        let grey50 = UIColor(white: 0.2, alpha: 1.0)
        let grey50Int = grey50.rgbInt32()
        XCTAssertEqual(refGrey50, grey50Int)

        let refGrey50Alpha: UInt32 = 0x333333ff
        let grey50AlphaInt = grey50.rgbInt32(withAlpha: true)
        XCTAssertEqual(refGrey50Alpha, grey50AlphaInt)
    }

    func testHexString() {
        let white = UIColor.white
        let whiteHex = white.hex()
        XCTAssertEqual(whiteHex, "ffffff")

        let whiteHexAlpha = white.hex(withAlpha: true)
        XCTAssertEqual(whiteHexAlpha, "ffffffff")
    }

    func testHexPrefix() {
        let white = UIColor.white
        let whiteHexPound = white.hex(prefix: .pound)
        XCTAssertEqual(whiteHexPound, "#ffffff")

        let whiteHexadecimal = white.hex(prefix: .hexadecimal)
        XCTAssertEqual(whiteHexadecimal, "0xffffff")

        let whiteHexCustom = white.hex(prefix: .custom("lol"))
        XCTAssertEqual(whiteHexCustom, "lolffffff")
    }

    func testHexInit() {
        let whiteHex = "ffffff"
        let white = UIColor(hexString: whiteHex)
        XCTAssertNotNil(white)
        XCTAssertEqual(whiteHex, white!.hex())

        let whiteHexAlpha = "ffffff33"
        let whiteAlpha = UIColor(hexString: whiteHexAlpha)
        XCTAssertNotNil(whiteAlpha)
        XCTAssertEqual(whiteHexAlpha, whiteAlpha!.hex(withAlpha: true))

        let whiteHexPoundPrefix = "#ffffff"
        let whitePoundPrefix = UIColor(hexString: whiteHexPoundPrefix)
        XCTAssertNotNil(whitePoundPrefix)
        XCTAssertEqual(whiteHexPoundPrefix, whitePoundPrefix!.hex(prefix: .pound))

        let whiteHexadecimalPrefix = "0xffffff"
        let whiteHexPrefix = UIColor(hexString: whiteHexadecimalPrefix)
        XCTAssertNotNil(whiteHexPrefix)
        XCTAssertEqual(whiteHexadecimalPrefix, whiteHexPrefix!.hex(prefix: .hexadecimal))

        let whiteHexCustomPrefix = "lolffffff"
        let whiteCustomPrefix = UIColor(hexString: whiteHex)
        XCTAssertNotNil(whiteCustomPrefix)
        XCTAssertEqual(whiteHexCustomPrefix, whiteCustomPrefix!.hex(prefix: .custom("lol")))
    }

    func testInvalidHexInit() {
        let blank = ""
        let blankColor = UIColor(hexString: blank)
        XCTAssertNil(blankColor)

        let tooShort = "12345"
        let tooShortColor = UIColor(hexString: tooShort)
        XCTAssertNil(tooShortColor)

        let tooShortPrefixed = "#12345"
        let tooShortPrefixedColor = UIColor(hexString: tooShortPrefixed)
        XCTAssertNil(tooShortPrefixedColor)

        let invalidHex = "ifoeifw3"
        let invalidHexColor = UIColor(hexString: invalidHex)
        XCTAssertNil(invalidHexColor)
    }
}
