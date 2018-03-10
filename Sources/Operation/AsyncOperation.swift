//
//  AsyncOperation.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 10/03/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    typealias Completion = (AsyncOperation) -> Void
    typealias Execution = (AsyncOperation) -> Void

    // The completionBlock property has unexpected behaviors such as
    // executing twice and executing on unexpected threads.
    @available(*, deprecated, message: "Use `completion` instead")
    override var completionBlock: (() -> Void)? {
        set {
            fatalError("The completionBlock property on NSOperation has unexpected behavior and is not supported 😈")
        }
        get {
            return nil
        }
    }

    /// `completion` serves the same purpose as `completionBlock` but will execute
    /// right before the operation is set as finished, not after. This means the
    /// operation is guaranteed to have completed all actions when it is finished.
    /// `completion` is executed regardless of cancel state.
    var completion: Completion?

    /// The work to be done. Will be skipped if operation is cancelled before starting.
    /// The code doing the work should periodically check for cancellation.
    /// If `execution` is set the code in the closure _must_ call `finish()` on the operation
    /// when the work is done.
    var execution: Execution?

    private let semaphore = DispatchSemaphore(value: 0)

    init(_ execution: Execution? = nil) {
        self.execution = execution
    }

    override func main() {
        defer {
            execution = nil
            completion?(self)
            completion = nil
        }

        guard !isCancelled, let execution = execution else {
            return
        }

        execution(self)
        semaphore.wait()
    }

    func finish() {
        semaphore.signal()
    }
}
