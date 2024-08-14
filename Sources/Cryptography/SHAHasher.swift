// BRToolKit
// Copyright © 2024 Bjørn Olav Ruud

import CryptoKit
import Foundation

public struct SHAHasher<SHAFunction: HashFunction>: HashFunction {
    public static var blockByteCount: Int {
        return SHAFunction.blockByteCount
    }

    private var hasher: SHAFunction

    public init() {
        self.hasher = SHAFunction()
    }

    public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
        hasher.update(bufferPointer: bufferPointer)
    }

    public mutating func update<D: DataProtocol>(data: D) {
        hasher.update(data: data)
    }

    public func finalize() -> SHAFunction.Digest {
        return hasher.finalize()
    }
}
