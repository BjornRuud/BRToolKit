//
//  ContinuousObservationTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 12/12/2024.
//  Copyright © 2024 BRToolKit. All rights reserved.
//

import Observation
import XCTest
@testable import BRToolKit

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
class ContinuousObservationTests: XCTestCase {
    @Observable
    final class Model: @unchecked Sendable {
        var counter = 0

        @ObservationIgnored
        var isCancelled = false
    }

    @MainActor
    func testMultipleObservations() {
        let expectWillChange = expectation(description: "willChange")
        let expectDidChange = expectation(description: "didChange")
        let model = Model()
        withObservationTracking {
            _ = model.counter
        } isCancelled: {
            model.isCancelled
        } willChange: {
            if model.counter == 1 {
                expectWillChange.fulfill()
            }
        } didChange: {
            if model.counter == 2 {
                expectDidChange.fulfill()
            }
        }

        Task {
            model.counter += 1
            Task {
                model.counter += 1
            }
        }
        waitForExpectations(timeout: 1.0)
    }
}
