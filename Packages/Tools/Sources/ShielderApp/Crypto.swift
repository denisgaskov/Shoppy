//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import CryptoKit
import Foundation

// MARK: - Crypto

enum Crypto {
  typealias Key = SymmetricKey
}

// MARK: - Key

extension Crypto {
  static func genKey() -> Key {
    SymmetricKey(size: .bits256)
  }
}

// MARK: - Encrypt

extension Crypto {
  static func encrypt(cryptoKey: Key, content: String) throws -> [UInt8] {
    let data = Data(content.utf8)
    let seal = try ChaChaPoly.seal(data, using: cryptoKey)
    return seal.combined.bytes
  }
}

// MARK: - SHA256

extension Crypto {
  static func SHA(content: String) throws -> String {
    let data = Data(content.utf8)
    let digest = SHA256.hash(data: data)
    return digest.compactMap { String(format: "%02x", $0) }.joined()
  }
}

// MARK: - ContiguousBytes + bytes

extension ContiguousBytes {
  var bytes: [UInt8] {
    withUnsafeBytes { pointer in
      Array(pointer.makeIterator())
    }
  }
}
