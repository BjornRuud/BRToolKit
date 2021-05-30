//
// Copyright © 2021 BRToolKit. All rights reserved. 
//

import Foundation

extension Comparable {
    func clamped(min: Self, max: Self) -> Self {
        if self < min {
            return min
        }
        if self > max {
            return max
        }
        return self
    }

    func clamped(to range: ClosedRange<Self>) -> Self {
        return self.clamped(min: range.lowerBound, max: range.upperBound)
    }

    func clamped(to range: Range<Self>) -> Self {
        return self.clamped(min: range.lowerBound, max: range.upperBound)
    }
}

@propertyWrapper
struct Clamped<Value> where Value: Comparable {
    var wrappedValue: Value {
        get { clampedValue }
        set { clampedValue = newValue.clamped(min: lowerBound, max: upperBound) }
    }

    private let lowerBound: Value
    private let upperBound: Value
    private var clampedValue: Value

    init(wrappedValue: Value, min: Value, max: Value) {
        self.lowerBound = min
        self.upperBound = max
        self.clampedValue = wrappedValue.clamped(min: min, max: max)
    }

    init(wrappedValue: Value, range: ClosedRange<Value>) {
        self.init(wrappedValue: wrappedValue, min: range.lowerBound, max: range.upperBound)
    }

    init(wrappedValue: Value, range: Range<Value>) {
        self.init(wrappedValue: wrappedValue, min: range.lowerBound, max: range.upperBound)
    }
}
