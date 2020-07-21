//
//  ReducerTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 21/07/2020.
//  Copyright © 2020 BRToolKit. All rights reserved.
//

import Combine
import XCTest
@testable import BRToolKit

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class ReducerTests: XCTestCase {

    enum Action {
        case add
        case asyncAdd
    }

    struct State {
        var value = 0
    }

    let reducer = Reducer<State, Action, Void> { state, action, _ in
        switch action {
        case .add:
            state.value += 1
            return nil

        case .asyncAdd:
            return Just(Action.add)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }

    var subscribers = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        subscribers.removeAll()
    }

    func testReducer() throws {
        var state = State()
        _ = reducer(&state, .add, ())
        XCTAssertEqual(state.value, 1)
    }

    func testSideEffect() throws {
        var state = State()

        guard let effect = reducer(&state, .asyncAdd, ()) else {
            XCTFail("Missing side effect")
            return
        }

        let expect = expectation(description: "")

        effect.sink { action in
            _ = self.reducer(&state, action, ())
            XCTAssertEqual(state.value, 1)
            expect.fulfill()
        }
        .store(in: &subscribers)

        waitForExpectations(timeout: 0.1)
    }

}
