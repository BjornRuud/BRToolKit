//
//  OperationGroup.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 10/03/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation

/// Runs a group of operations concurrently and finishes when all operations
/// in the group are either cancelled or finished.
class OperationGroup: AsyncOperation {
    let operations: [Operation]

    private let queue = OperationQueue()

    init(_ operations: [Operation], completion: Completion? = nil) {
        self.operations = operations

        super.init()

        self.completion = completion

        self.execution = { [weak self] (_) in
            self?.execute()
        }

        queue.isSuspended = true
        queue.addOperations(operations, waitUntilFinished: false)

        // The final operation runs after all others and finishes the operation group
        let finalOperation = BlockOperation { [weak self] in
            self?.finish()
        }

        operations.forEach { finalOperation.addDependency($0) }
        queue.addOperation(finalOperation)
    }

    override func cancel() {
        super.cancel()

        operations.forEach { $0.cancel() }
        queue.isSuspended = false
    }

    private func execute() {
        if let currentQueue = OperationQueue.current {
            queue.qualityOfService = currentQueue.qualityOfService
        }

        queue.isSuspended = false
    }
}
