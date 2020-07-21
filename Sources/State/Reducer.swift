//
//  Reducer.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 27/06/2020.
//  Copyright © 2020 BRToolKit. All rights reserved.
//

#if canImport(Combine)
import Combine
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct Reducer<State, Action, Environment> {
    public let reduce: (inout State, Action, Environment) -> AnyPublisher<Action, Never>?

    public init(
        _ reducer: @escaping (inout State, Action, Environment) -> AnyPublisher<Action, Never>?
    ) {
        self.reduce = reducer
    }

    public func callAsFunction(
        _ state: inout State,
        _ action: Action,
        _ environment: Environment
    ) -> AnyPublisher<Action, Never>? {
        return reduce(&state, action, environment)
    }
}
#endif
