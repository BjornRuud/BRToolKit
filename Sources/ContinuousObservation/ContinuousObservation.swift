//
//  ContinuousObservation.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 01/05/2024.
//  Copyright © 2024 BRToolKit. All rights reserved.
//

#if canImport(Observation)
import Observation

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
func withObservationTracking(
    _ apply: @escaping @Sendable () -> Void,
    isCancelled: @escaping @Sendable () -> Bool,
    willChange: (@Sendable () -> Void)? = nil,
    didChange: @escaping @Sendable () -> Void
) {
    withObservationTracking(apply) {
        if isCancelled() { return }
        willChange?()
        Task {
            didChange()
            withObservationTracking(
                apply,
                isCancelled: isCancelled,
                willChange: willChange,
                didChange: didChange
            )
        }
    }
}
#endif
