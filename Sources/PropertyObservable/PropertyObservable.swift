//
//  PropertyObservable.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 18/03/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation

/// Represents a property change from an old value to a new value.
public struct PropertyChange<T> {
    let oldValue: T
    let newValue: T
}

/// An observable event for a property.
public enum PropertyEvent<T> {
    case willSet(PropertyChange<T>)
    case didSet(PropertyChange<T>)
}

/// The function signature for property event observations.
public typealias PropertyObservation<T> = (PropertyEvent<T>) -> Void

/// An opaque type representing a property observer.
/// When the observer is deallocated the observation is removed.
public final class PropertyObserver {
    fileprivate let key: PropertyObserverManager.ObjectPropertyKey

    fileprivate let observationID = UUID()

    private weak var manager: PropertyObserverManager?

    fileprivate init(key: PropertyObserverManager.ObjectPropertyKey, manager: PropertyObserverManager) {
        self.key = key
        self.manager = manager
    }

    deinit {
        manager?.removeObserver(self)
    }
}

/**
 Enables property observation. All functions have default implementations so just add the
 protocol to the class and you're done.
 */
public protocol PropertyObservable: class {
    /**
     Register an observation closure for a property event on this object.

     - Parameter property: The property `KeyPath`.
     - Parameter queue: Optional dispatch queue to execute the observation on. If no queue
                        is provided the observation is executed on the same thread that triggered
                        the property event.
     - Parameter observation: A closure that will be called for all events for this `KeyPath`.

     - Returns: An opaque object representing the observation.
                The observation has the same lifetime as the returned `PropertyObserver` object.
     */
    func observe<T, V>(property: KeyPath<T, V>, queue: DispatchQueue?, observation: @escaping PropertyObservation<V>) -> PropertyObserver

    /**
     Convenience function to only observe `willSet` events.

     - Parameter property: The property `KeyPath`.
     - Parameter queue: Optional dispatch queue for the observation closure.
                        See `observe(property:queue:observation:)` for details.
     - Parameter observation: A closure that will be called with the change involved in the `willSet` event for this property.

     - Returns: An opaque object representing the observation.
     */
    func observeWillSet<T, V>(property: KeyPath<T, V>, queue: DispatchQueue?, observation: @escaping (PropertyChange<V>) -> Void) -> PropertyObserver

    /**
     Convenience function to only observe `didSet` events.

     - Parameter property: The property `KeyPath`.
     - Parameter queue: Optional dispatch queue for the observation closure.
                        See `observe(property:queue:observation:)` for details.
     - Parameter observation: A closure that will be called with the change involved in the `didSet` event for this property.

     - Returns: An opaque object representing the observation.
     */
    func observeDidSet<T, V>(property: KeyPath<T, V>, queue: DispatchQueue?, observation: @escaping (PropertyChange<V>) -> Void) -> PropertyObserver

    /**
     Signals observers that a `PropertyEvent` happened for a `KeyPath` on this object.

     - Parameter property: The property `KeyPath`.
     - Parameter event: The `PropertyEvent` to send to observers.
     */
    func propertyEvent<T, V>(_ property: KeyPath<T, V>, _ event: PropertyEvent<V>)

    /**
     Convenience function to signal observers that a `willSet` event happened for a `KeyPath` on this object.

     - Parameter property: The property `KeyPath`.
     - Parameter oldValue: The current value.
     - Parameter newValue: The new value.
     */
    func propertyWillSet<T, V>(_ property: KeyPath<T, V>, oldValue: V, newValue: V)

    /**
     Convenience function to signal observers that a `didSet` event happened for a `KeyPath` on this object.

     - Parameter property: The property `KeyPath`.
     - Parameter oldValue: The previous value.
     - Parameter newValue: The current value.
     */
    func propertyDidSet<T, V>(_ property: KeyPath<T, V>, oldValue: V, newValue: V)
}

/**
 Default implementations for the `PropertyObservable` protocol.
 Do not override unless you want to provide completely custom observation management.
 If you _do_ want custom management, you only have to override `observe(property:observation:)` and
 `propertyEvent(_:_:)` since the rest are convenience wrappers.
*/
public extension PropertyObservable {
    public func observe<T, V>(property: KeyPath<T, V>, queue: DispatchQueue? = nil, observation: @escaping PropertyObservation<V>) -> PropertyObserver {
        return PropertyObserverManager.shared.observe(object: self, property: property, queue: queue, observation: observation)
    }

    public func observeWillSet<T, V>(property: KeyPath<T, V>, queue: DispatchQueue? = nil, observation: @escaping (PropertyChange<V>) -> Void) -> PropertyObserver {
        return observe(property: property, queue: queue) { (event) in
            if case .willSet(let change) = event {
                observation(change)
            }
        }
    }

    public func observeDidSet<T, V>(property: KeyPath<T, V>, queue: DispatchQueue? = nil, observation: @escaping (PropertyChange<V>) -> Void) -> PropertyObserver {
        return observe(property: property, queue: queue) { (event) in
            if case .didSet(let change) = event {
                observation(change)
            }
        }
    }

    public func propertyEvent<T, V>(_ property: KeyPath<T, V>, _ event: PropertyEvent<V>) {
        PropertyObserverManager.shared.propertyEvent(event, for: property, on: self)
    }

    public func propertyWillSet<T, V>(_ property: KeyPath<T, V>, oldValue: V, newValue: V) {
        propertyEvent(property, .willSet(PropertyChange(oldValue: oldValue, newValue: newValue)))
    }

    public func propertyDidSet<T, V>(_ property: KeyPath<T, V>, oldValue: V, newValue: V) {
        propertyEvent(property, .didSet(PropertyChange(oldValue: oldValue, newValue: newValue)))
    }
}

fileprivate final class PropertyObserverManager {

    private final class ObservationWrapper {
        let typeErasedObservation: Any
        let queue: DispatchQueue?

        init(observation: Any, queue: DispatchQueue?) {
            self.typeErasedObservation = observation
            self.queue = queue
        }
    }

    fileprivate final class ObjectPropertyKey: Hashable {
        private let objectID: ObjectIdentifier

        private let property: AnyKeyPath

        init(object: AnyObject, property: AnyKeyPath) {
            self.objectID = ObjectIdentifier(object)
            self.property = property
        }

        // MARK: Equatable

        static func ==(lhs: ObjectPropertyKey, rhs: ObjectPropertyKey) -> Bool {
            return lhs.objectID == rhs.objectID && lhs.property == rhs.property
        }

        // MARK: Hashable

        var hashValue: Int {
            return objectID.hashValue ^ property.hashValue
        }
    }

    static let shared = PropertyObserverManager()

    private let lock = NSLock()

    private var observerMap = [ObjectPropertyKey: [UUID: ObservationWrapper]]()

    func propertyEvent<T, V>(_ event: PropertyEvent<V>, for property: KeyPath<T, V>, on object: AnyObject) {
        lock.lock()
        defer { lock.unlock() }

        let key = ObjectPropertyKey(object: object, property: property)

        guard let allObservations = observerMap[key] else {
            return
        }

        allObservations.forEach { (_, wrapper) in
            guard let observation = wrapper.typeErasedObservation as? PropertyObservation<V> else {
                assertionFailure("Observation value types should match.")
                return
            }

            if let queue = wrapper.queue {
                queue.async {
                    observation(event)
                }
            } else {
                observation(event)
            }
        }
    }

    func observe<T, V>(object: AnyObject, property: KeyPath<T, V>, queue: DispatchQueue? = nil, observation: @escaping PropertyObservation<V>) -> PropertyObserver {
        lock.lock()
        defer { lock.unlock() }

        let key = ObjectPropertyKey(object: object, property: property)

        let observer = PropertyObserver(key: key, manager: self)

        var observations = observerMap[key] ?? [:]
        observations[observer.observationID] = ObservationWrapper(observation: observation, queue: queue)
        observerMap[key] = observations

        return observer
    }

    func removeObserver(_ observer: PropertyObserver) {
        lock.lock()
        defer { lock.unlock() }

        guard var observations = observerMap[observer.key] else {
            return
        }

        observations[observer.observationID] = nil
        observerMap[observer.key] = observations.isEmpty ? nil : observations
    }
}
