//
//  OperationGroupTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 10/03/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation
import XCTest
@testable import BRToolKit

class OperationGroupTests: XCTestCase {

    let lock = NSLock()

    let queue = OperationQueue()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()

        queue.cancelAllOperations()
    }

    func testOperationGroup() {
        let exp = expectation(description: "All done")

        var done1 = false
        var done2 = false
        var done3 = false

        let op1 = BlockOperation {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            done1 = true
        }
        let op2 = BlockOperation {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            done2 = true
        }
        let op3 = BlockOperation {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            done3 = true
        }

        let group = OperationGroup([op1, op2, op3]) { (_) in
            if done1 && done2 && done3 {
                exp.fulfill()
            } else {
                XCTFail("Group operations not done")
            }
        }
        queue.addOperation(group)
        waitForExpectations(timeout: 5)
    }

    func testOperationGroupInGroup() {
        let exp = expectation(description: "All done")

        var done1 = false
        var done2 = false
        var done3 = false
        var innerDone = false

        let op1 = BlockOperation { [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            done1 = true
        }
        let op2 = BlockOperation { [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            done2 = true
        }
        let op3 = BlockOperation { [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            done3 = true
        }

        let innerGroup = OperationGroup([op2, op3]) { [unowned self] (_) in
            self.lock.lock()
            defer { self.lock.unlock() }
            innerDone = true
        }

        let outerGroup = OperationGroup([op1, innerGroup]) { (_) in
            if done1 && done2 && done3 && innerDone {
                exp.fulfill()
            } else {
                XCTFail("Group operations not done")
            }
        }

        queue.addOperation(outerGroup)
        waitForExpectations(timeout: 5)
    }

    func testOperationGroupCancel() {
        let exp = expectation(description: "All done")

        let op1 = BlockOperation()
        let op2 = BlockOperation()
        let op3 = BlockOperation()

        let group = OperationGroup([op1, op2, op3]) { (_) in
            if !op1.isCancelled, op2.isCancelled, !op3.isCancelled {
                exp.fulfill()
            } else {
                XCTFail("Cancel operation in group failed")
            }
        }
        op2.cancel()
        queue.addOperation(group)
        waitForExpectations(timeout: 5)
    }

    func testOperationGroupCancelAll() {
        let exp = expectation(description: "All done")

        var cancelCount = 0
        var runCount = 0

        let op1 = BlockOperation()
        let op2 = BlockOperation()
        let op3 = BlockOperation()

        let ops = [op1, op2, op3]

        let group = OperationGroup(ops) { (_) in
            if cancelCount == 3 {
                exp.fulfill()
            } else {
                XCTFail("Should have been cancelled")
            }
        }

        func waitForCancel(_ operation: BlockOperation) {
            self.lock.lock()
            runCount += 1
            if runCount == 3 {
                group.cancel()
            }
            self.lock.unlock()
            while !operation.isCancelled {
                let sleepTime = useconds_t(Double(USEC_PER_SEC) * 0.01)
                usleep(sleepTime)
            }
            self.lock.lock()
            cancelCount += 1
            self.lock.unlock()
        }

        for op in ops {
            op.addExecutionBlock { [unowned op] in
                waitForCancel(op)
            }
        }

        queue.addOperation(group)
        waitForExpectations(timeout: 5)
    }
}
