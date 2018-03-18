//
//  PropertyObservableTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 18/03/2018.
//  Copyright © 2018 BRToolKit. All rights reserved.
//

import Foundation
import XCTest
@testable import BRToolKit

class PropertyObservableTests: XCTestCase {

    class Book: PropertyObservable {
        var title: String {
            willSet {
                propertyWillSet(\Book.title, oldValue: title, newValue: newValue)
            }
            didSet {
                propertyDidSet(\Book.title, oldValue: oldValue, newValue: title)
            }
        }

        init(title: String) {
            self.title = title
        }
    }

    override func setUp() {
        super.setUp()

        observer = nil
        observer2 = nil
        book = Book(title: oldTitle)
    }

    override func tearDown() {
        super.tearDown()
    }

    let oldTitle = "Foo"
    let newTitle = "Bar"
    let titleProperty = \Book.title

    var book: Book!

    var observer: PropertyObserver?
    var observer2: PropertyObserver?

    func testEventObservation() {
        var observedWillSet = false
        var observedDidSet = false

        observer = book.observe(property: titleProperty) { (event) in
            switch event {
            case .willSet(let change):
                XCTAssertTrue(change.oldValue == self.oldTitle)
                XCTAssertTrue(change.newValue == self.newTitle)
                observedWillSet = true
            case .didSet(let change):
                XCTAssertTrue(change.oldValue == self.oldTitle)
                XCTAssertTrue(change.newValue == self.newTitle)
                observedDidSet = true
            }
        }

        book.title = newTitle
        XCTAssertTrue(observedWillSet)
        XCTAssertTrue(observedDidSet)
    }

    func testWillSetObservation() {
        var observedWillSet = false

        observer = book.observeWillSet(property: titleProperty) { (change) in
            XCTAssertTrue(change.oldValue == self.oldTitle)
            XCTAssertTrue(change.newValue == self.newTitle)
            observedWillSet = true
        }

        book.title = newTitle
        XCTAssertTrue(observedWillSet)
    }

    func testDidSetObservation() {
        var observedDidSet = false

        observer = book.observeDidSet(property: titleProperty) { (change) in
            XCTAssertTrue(change.oldValue == self.oldTitle)
            XCTAssertTrue(change.newValue == self.newTitle)
            observedDidSet = true
        }

        book.title = newTitle
        XCTAssertTrue(observedDidSet)
    }

    func testMultipleObservers() {
        var observedDidSet1 = false
        var observedDidSet2 = false

        observer = book.observeDidSet(property: titleProperty) { (change) in
            XCTAssertTrue(change.oldValue == self.oldTitle)
            XCTAssertTrue(change.newValue == self.newTitle)
            observedDidSet1 = true
        }

        observer2 = book.observeDidSet(property: titleProperty) { (change) in
            XCTAssertTrue(change.oldValue == self.oldTitle)
            XCTAssertTrue(change.newValue == self.newTitle)
            observedDidSet2 = true
        }

        book.title = newTitle
        XCTAssertTrue(observedDidSet1)
        XCTAssertTrue(observedDidSet2)
    }
}
