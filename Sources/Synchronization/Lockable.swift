//
//  Lockable.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 28/04/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation

public protocol Lockable: AnyObject {
    func lock()
    func unlock()
    func tryLock() -> Bool
}
