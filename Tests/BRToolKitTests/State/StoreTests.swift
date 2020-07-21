//
//  StoreTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 21/07/2020.
//  Copyright © 2020 BRToolKit. All rights reserved.
//

import Combine
import XCTest
@testable import BRToolKit

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class StoreTests: XCTestCase {

    enum Action {
        case add
    }

    struct State {
        var value = 0
    }

    let reducer = Reducer<State, Action, Void> { state, action, _ in
        switch action {
        case .add:
            state.value += 1
            return nil
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

    func testStore() throws {
        let store = Store(initialState: State(), reducer: reducer)
        store.send(.add)
        XCTAssertEqual(store.state.value, 1)
        XCTAssertEqual(store.value, 1)
    }

    func testSubscription() throws {
        let expect = expectation(description: "")
        let store = Store(initialState: State(), reducer: reducer)

        store.sink { state in
            XCTAssertEqual(state.value, 1)
            expect.fulfill()
        }
        .store(in: &subscribers)

        store.send(.add)
        waitForExpectations(timeout: 0.1)
    }

}
