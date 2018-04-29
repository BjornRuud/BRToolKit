//
//  MutexLock.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 28/04/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation

public final class MutexLock: Lockable {
    private var mutex: pthread_mutex_t

    public init() {
        mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    public func lock() {
        pthread_mutex_lock(&mutex)
    }

    public func unlock() {
        pthread_mutex_unlock(&mutex)
    }

    public func tryLock() -> Bool {
        return pthread_mutex_trylock(&mutex) == 0
    }
}
