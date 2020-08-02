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
    private let unfairLock: os_unfair_lock_t

    public init() {
        // Perform manual allocation because of how the Swift compiler automatically
        // allocates memory for C types (in order to avoid a rare crash).
        //
        // https://forums.swift.org/t/atomic-property-wrapper-for-standard-library/30468/18
        //
        // Philippe_Hausler:
        // This is a two fold issue; 1) the compiler is completely at liberty to write something
        // back to the taking of the address of a struct (say to write tombstone values) and 2)
        // the allocation region may not be heap, in the regards types can be allocated on the
        // stack if the compiler has knowledge of that type and the lifespan of the usage. So as
        // it stands the only safe way (and by safe I mean way without a crash rate) is to
        // allocate a region via something like os_unfair_lock_t.allocate(1) and use the resultant
        // of that to pass into os_unfair_lock_lock.
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: .init())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    public func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    public func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }

    public func tryLock() -> Bool {
        return os_unfair_lock_trylock(unfairLock)
    }
}
