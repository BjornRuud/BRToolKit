//
//  OperationSequenceTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 10/03/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation
import XCTest
@testable import BRToolKit

class OperationSequenceTests: XCTestCase {

    let lock = NSLock()

    let queue = OperationQueue()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()

        queue.cancelAllOperations()
    }

    func testOperationSequence() {
        let exp = expectation(description: "All done")

        var done1 = false
        var done2 = false
        var done3 = false

        let op1 = BlockOperation {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            XCTAssertFalse(done1)
            XCTAssertFalse(done2)
            XCTAssertFalse(done3)
            done1 = true
        }
        let op2 = BlockOperation {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            XCTAssertTrue(done1)
            XCTAssertFalse(done2)
            XCTAssertFalse(done3)
            done2 = true
        }
        let op3 = BlockOperation {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            XCTAssertTrue(done1)
            XCTAssertTrue(done2)
            XCTAssertFalse(done3)
            done3 = true
        }

        let seq = OperationSequence([op1, op2, op3]) { (_) in
            if done1 && done2 && done3 {
                exp.fulfill()
            } else {
                XCTFail("All sequence operations not done")
            }
        }
        queue.addOperation(seq)
        waitForExpectations(timeout: 5)
    }

    func testOperationSequenceCancel() {
        let exp = expectation(description: "All done")

        let op1 = BlockOperation()
        let op2 = BlockOperation()
        let op3 = BlockOperation()
        let op4 = BlockOperation()

        var done1 = false
        var done2 = false
        var done3 = false
        var done4 = false

        op1.addExecutionBlock {
            [unowned self, unowned op1] in
            self.lock.lock()
            defer { self.lock.unlock() }
            if op1.isCancelled {
                XCTFail("Shouldn't be cancelled")
            }
            done1 = true
        }

        op2.addExecutionBlock {
            [unowned self, unowned op2, unowned op3] in
            self.lock.lock()
            defer { self.lock.unlock() }
            if op2.isCancelled {
                XCTFail("Shouldn't be cancelled")
            }
            done2 = true
            op3.cancel()
        }

        op3.addExecutionBlock {
            [unowned self, unowned op3] in
            self.lock.lock()
            defer { self.lock.unlock() }
            if !op3.isCancelled {
                done3 = true
                XCTFail("Should be cancelled")
            }
        }

        op4.addExecutionBlock {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            if done3 {
                done4 = true
                XCTFail("Previous operation should be cancelled")
            }
        }

        let seq = OperationSequence([op1, op2, op3, op4]) { (operation) in
            if done1 && done2 && !done3 && !done4 {
                exp.fulfill()
            } else {
                XCTFail("Sequence not cancelled correctly")
            }
        }
        queue.addOperation(seq)
        waitForExpectations(timeout: 5)
    }

    func testOperationSequenceCancelAll() {
        let exp = expectation(description: "All done")

        let op1 = BlockOperation()
        let op2 = BlockOperation()
        let op3 = BlockOperation()

        let ops = [op1, op2, op3]

        let seq = OperationSequence(ops) { (operation) in
            if operation.isCancelled && op1.isCancelled && op2.isCancelled && op3.isCancelled {
                exp.fulfill()
            } else {
                XCTFail("Should have been cancelled")
            }
        }

        op1.addExecutionBlock { [unowned seq] in
            seq.cancel()
        }

        queue.addOperation(seq)
        waitForExpectations(timeout: 5)
    }

    func testOperationSequenceWithGroup() {
        let exp = expectation(description: "All done")

        var done1 = false
        var done2 = false
        var done3 = false

        let op1 = BlockOperation {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            XCTAssertFalse(done1)
            XCTAssertFalse(done2)
            XCTAssertFalse(done3)
            done1 = true
        }

        let op2 = BlockOperation {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            XCTAssertTrue(done1)
            done2 = true
        }

        let op3 = BlockOperation {
            [unowned self] in
            self.lock.lock()
            defer { self.lock.unlock() }
            XCTAssertTrue(done1)
            done3 = true
        }

        let group = OperationGroup([op2, op3])

        let seq = OperationSequence([op1, group])

        group.completion = { (_) in
            XCTAssertTrue(done2 && done3)
        }

        seq.completion = { (_) in
            if done1 && done2 && done3 {
                exp.fulfill()
            } else {
                XCTFail("All sequence operations not done")
            }
        }

        queue.addOperation(seq)
        waitForExpectations(timeout: 5)
    }
}
