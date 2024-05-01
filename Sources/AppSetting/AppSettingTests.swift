//
//  AppSettingTests.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 31/01/2021.
//  Copyright © 2021 BRToolKit. All rights reserved.
//

import XCTest
@testable import BRToolKit

class AppSettingTests: XCTestCase {

    static let userNameAppKey = AppSettingKey(id: "username", defaultValue: "test")
    static let userNameKey = UserDefaultsStorageKey(id: "username", defaultValue: "test")

    final class Model {
        @AppSetting(key: AppSettingTests.userNameAppKey, storage: AppSettingUserDefaultsStorage())
        var userName: String

        @UserDefaultsStorage(key: AppSettingTests.userNameKey)
        var userNameApp: String

        init() {}
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
