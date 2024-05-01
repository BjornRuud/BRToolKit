//
//  AppSetting.swift
//  BRToolKit
//
//  Created by Bjørn Olav Ruud on 31/01/2021.
//  Copyright © 2021 BRToolKit. All rights reserved.
//

import Foundation

public protocol AppSettingStorage {
    associatedtype Key

    func appSetting(forKey key: Key) -> Any?
    mutating func setAppSetting(_ value: Any?, forKey key: Key)
}

extension AppSettingStorage {
    static var userDefaults: AppSettingUserDefaultsStorage {
        return AppSettingUserDefaultsStorage()
    }
}

public struct AppSettingUserDefaultsStorage: AppSettingStorage {
    private let storage: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.storage = userDefaults
    }

    public func appSetting(forKey key: String) -> Any? {
        return storage.object(forKey: key)
    }

    public mutating func setAppSetting(_ value: Any?, forKey key: String) {
        storage.set(value, forKey: key)
    }
}

public struct AppSettingKey<ID, Value> {
    public let id: ID
    public let defaultValue: Value
}

@propertyWrapper
public struct AppSetting<Value, Storage> where Storage: AppSettingStorage {
    public let key: AppSettingKey<Storage.Key, Value>
    private var storage: Storage

    public var wrappedValue: Value {
        get {
            return (storage.appSetting(forKey: key.id) as? Value) ?? key.defaultValue
        }
        set {
            storage.setAppSetting(newValue, forKey: key.id)
        }
    }

    public init(
        key: AppSettingKey<Storage.Key, Value>,
        storage: Storage
    ) {
        self.key = key
        self.storage = storage
    }
}

public struct UserDefaultsStorageKey<Value> {
    public let id: String
    public let defaultValue: Value
}

@propertyWrapper
public struct UserDefaultsStorage<Value> {
    public let key: UserDefaultsStorageKey<Value>
    private let storage: UserDefaults

    public var wrappedValue: Value {
        get {
            return (storage.object(forKey: key.id) as? Value) ?? key.defaultValue
        }
        set {
            storage.set(newValue, forKey: key.id)
        }
    }

    public init(
        key: UserDefaultsStorageKey<Value>,
        storage: UserDefaults = .standard
    ) {
        self.key = key
        self.storage = storage
    }
}

@propertyWrapper
public struct UserDefaultsSetting<Value> {
    public let key: String
    private let storage: UserDefaults

    public var wrappedValue: Value {
        get {
            return storage.object(forKey: key) as! Value
        }
        set {
            storage.set(newValue, forKey: key)
        }
    }

    public init(
        key: String,
        defaultValue: Value,
        userDefaults: UserDefaults = .standard
    ) {
        self.key = key
        self.storage = userDefaults
        userDefaults.register(defaults: [key: defaultValue])
    }
}
