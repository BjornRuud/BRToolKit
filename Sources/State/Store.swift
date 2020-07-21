//
//  Store.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 01/06/2020.
//  Copyright © 2020 BRToolKit. All rights reserved.
//

#if canImport(Combine)

import Combine
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
@dynamicMemberLookup
public final class Store<State, Action>: ObservableObject {
    private let publisher = PassthroughSubject<State, Never>()

    public private(set) var state: State {
        willSet {
            objectWillChange.send()
        }
        didSet {
            publisher.send(state)
        }
    }

    private let reducer: (inout State, Action) -> AnyPublisher<Action, Never>?

    private var sideEffects: [UUID: AnyCancellable] = [:]

    public init<Environment>(
        initialState: State,
        environment: Environment,
        reducer: Reducer<State, Action, Environment>
    ) {
        self.state = initialState

        self.reducer = { state, action in
            return reducer(&state, action, environment)
        }
    }

    public convenience init(
        initialState: State,
        reducer: Reducer<State, Action, Void>
    ) {
        self.init(initialState: initialState, environment: (), reducer: reducer)
    }

    /**
     Convenience subscript to access the State properties through the Store.
     */
    public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        return state[keyPath: keyPath]
    }

    /**
     Send an action to the state and execute a side effect (if any) created by the action.

     This function is not thread-safe, so make sure to use `receive(on:options:)` on side effects
     to receive completions _after_ the call to `send(_:)` that created the side effect has
     completed.

     - Parameter action: The action sent to the state and handled by the reducer.
     */
    public func send(_ action: Action) {
        guard let effect = reducer(&state, action) else {
            return
        }
        let uuid = UUID()
        sideEffects[uuid] = effect.sink(receiveCompletion: {
            [weak self] _ in
            self?.sideEffects[uuid] = nil
        }, receiveValue: {
            [weak self] action in
            self?.send(action)
        })
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Store: Publisher {
    public typealias Output = State
    public typealias Failure = Never

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
}

#endif
