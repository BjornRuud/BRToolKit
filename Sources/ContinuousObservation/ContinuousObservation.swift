//
//  ContinuousObservation.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 01/05/2024.
//  Copyright © 2024 BRToolKit. All rights reserved.
//

import Foundation

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
final class ContinuousObserver: @unchecked Sendable {
    private var _isCancelled: Bool = false

    var isCancelled: Bool {
        return queue.sync {
            return _isCancelled
        }
    }

    private let queue = DispatchQueue(label: "ContinuousObserver.queue", attributes: .concurrent)

    func cancel() {
        queue.sync(flags: .barrier) {
            _isCancelled = true
        }
    }

    func startObserving(
        _ apply: @escaping @Sendable () -> Void,
        onChange: @autoclosure @escaping @Sendable () -> @Sendable () -> Void
    ) {
        queue.sync {
            _startObserving(apply, onChange: onChange())
        }
    }

    private func _startObserving(
        _ apply: @escaping @Sendable () -> Void,
        onChange: @escaping @Sendable () -> Void
    ) {
        if _isCancelled { return }
        withObservationTracking(apply) { [weak self] in
            guard let self else { return }
            onChange()
            self.queue.async { [weak self] in
                self?.startObserving(apply, onChange: onChange)
            }
        }
    }
}

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
func withContinuousObservation(
    _ apply: @escaping @Sendable () -> Void,
    onChange: @autoclosure @escaping @Sendable () -> @Sendable () -> Void
) -> ContinuousObserver {
    let observer = ContinuousObserver()
    observer.startObserving(apply, onChange: onChange())
    return observer
}
