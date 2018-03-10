//
//  AsyncOperationTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 10/03/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation
import XCTest
@testable import BRToolKit

class AsyncOperationTests: XCTestCase {

    let lock = NSLock()

    let queue = OperationQueue()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()

        queue.cancelAllOperations()
    }

    func testAsyncOperation() {
        let exp = expectation(description: "")

        var done1 = false

        let op1 = AsyncOperation { (operation) in
            DispatchQueue.global(qos: .userInitiated).async {
                done1 = true
                operation.finish()
            }
        }
        op1.completion = { (_) in
            XCTAssertTrue(done1)
            exp.fulfill()
        }

        queue.addOperation(op1)
        waitForExpectations(timeout: 5)
    }

    func testAsyncDependency() {
        let exp = expectation(description: "")

        var done1 = false
        var done2 = false

        let op1 = AsyncOperation { (operation) in
            done1 = true
            operation.finish()
        }

        let op2 = AsyncOperation { (operation) in
            done2 = true
            operation.finish()
        }

        let finalOp = AsyncOperation { (operation) in
            XCTAssertTrue(done1 && done2)
            exp.fulfill()
            operation.finish()
        }
        finalOp.addDependency(op1)
        finalOp.addDependency(op2)

        queue.addOperations([op1, op2, finalOp], waitUntilFinished: false)

        waitForExpectations(timeout: 5)
    }
}
