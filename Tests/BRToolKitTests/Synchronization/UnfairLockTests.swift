//
//  UnfairLockTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 29/04/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation
import XCTest
@testable import BRToolKit

class UnfairLockTests: XCTestCase {

    let lock = UnfairLock()

    let queue = DispatchQueue(label: "UnfairLockTests")

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLock() {
        let exp = expectation(description: "")

        queue.async {
            self.lock.lock()
            DispatchQueue.global(qos: .userInitiated).sync {
                XCTAssertFalse(self.lock.tryLock())
            }
            self.lock.unlock()
            DispatchQueue.global(qos: .userInitiated).sync {
                XCTAssertTrue(self.lock.tryLock())
                self.lock.unlock()
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
