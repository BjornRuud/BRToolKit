//
//  UnfairLock.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 28/04/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation

@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)
public final class UnfairLock: Lockable {
    private var unfairLock = os_unfair_lock()

    public func lock() {
        os_unfair_lock_lock(&unfairLock)
    }

    public func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }

    public func tryLock() -> Bool {
        return os_unfair_lock_trylock(&unfairLock)
    }
}
