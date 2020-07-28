//
//  Store+SwiftUI.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 28/07/2020.
//  Copyright © 2020 BRToolKit. All rights reserved.
//

#if canImport(Combine)

import Foundation
import SwiftUI

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Store {
    func binding<Value>(
        get keyPath: KeyPath<State, Value>,
        send action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        .init(get: {
            self.state[keyPath: keyPath]
        }, set: {
            self.send(action($0))
        })
    }
}

#endif
