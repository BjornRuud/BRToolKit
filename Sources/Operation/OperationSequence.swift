//
//  OperationSequence.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 10/03/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation

/// Runs operations in the same sequence as the input array, with each operation waiting
/// for the preceding one to finish before executing.
class OperationSequence: OperationGroup {
    override init(_ operations: [Operation], completion: Completion? = nil) {
        super.init(operations, completion: completion)

        // Consecutive operations are dependent on the previous one
        var maybePrevious: Operation?
        for op in operations {
            guard let previous = maybePrevious else {
                maybePrevious = op
                continue
            }

            op.addDependency(previous)
            maybePrevious = op
        }
    }
}
