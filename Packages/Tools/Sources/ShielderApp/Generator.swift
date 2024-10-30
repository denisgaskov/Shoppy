//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

// MARK: - AccessModifier

enum AccessModifier: String {
  case `internal`
  case `public`

  init(envLock: File) throws {
    guard let value = envLock["shielder_access_modifier"] else {
      // if value is not present, assume it's internal by default
      self = .internal
      return
    }

    if let value = Self(rawValue: value) {
      self = value
    } else {
      throw TextError(at: envLock.path, "AccessModifier \(value) is not valid.")
    }
  }
}

// MARK: - Generator

struct Generator {
  private let abbreviations = ["ID", "URL", "UUID", "API"]
  private let access: AccessModifier
  let envContent: [File.Entry]
  let cryptoKey: Crypto.Key

  init(envContent: [File.Entry], access: AccessModifier, cryptoKey: Crypto.Key = Crypto.genKey()) {
    self.access = access
    self.envContent = envContent
    self.cryptoKey = cryptoKey
  }

  func generateSwift() throws -> String {
    func generateProperties(transform: (_ entry: File.Entry) throws -> String) throws -> String {
      try envContent
        .map { entry in
          try "  " + transform(entry)
        }
        .joined(separator: "\n\n")
    }

    let protocolProperties = try generateProperties(transform: protocolProperty(from:))
    let structProperties = try generateProperties(transform: structPropery(from:))

    return [
      fileHeader(),
      secretsDeclaration(properties: protocolProperties),
      shielderSecretsDeclaration(properties: structProperties)
    ].joined(separator: "\n\n")
  }

  private func protocolProperty(from entry: File.Entry) -> String {
    let key = transformKey(key: entry.key)
    return "var \(key): \(entry.type.typeName) { get }"
  }

  private func structPropery(from entry: File.Entry) throws -> String {
    let key = transformKey(key: entry.key)
    let bytes = try Crypto.encrypt(cryptoKey: cryptoKey, content: entry.value)

    let type = entry.type
    return "\(access) var \(key): \(type.typeName) { \(type.initDecl(stringValue: "decrypt(\(bytes))")) }"
  }

  private func transformKey(key: String) -> String {
    key
      .components(separatedBy: .punctuationCharacters)
      .enumerated()
      .map { index, word in
        if abbreviations.contains(word.uppercased()) {
          word.uppercased()
        } else if index == 0 {
          word.lowercased()
        } else {
          word.capitalized
        }
      }
      .joined()
  }
}

// MARK: - ValueType + Swift

extension File.Entry.ValueType {
  fileprivate var typeName: String {
    switch self {
      case .url: "URL"
      case .string: "String"
    }
  }

  fileprivate func initDecl(stringValue: String) -> String {
    switch self {
      case .url: "URL(string: \(stringValue))!"
      case .string: stringValue
    }
  }
}

// MARK: - Swift code templates

extension Generator {
  private func fileHeader() -> String {
    """
    import Foundation
    import CryptoKit

    private let keyBytes: [UInt8] = \(cryptoKey.bytes)
    private var key: SymmetricKey { SymmetricKey(data: keyBytes) }

    private func decrypt(_ bytes: [UInt8]) -> String {
      if
        let sealedBox = try? ChaChaPoly.SealedBox(combined: bytes),
        let decodedData = try? ChaChaPoly.open(sealedBox, using: key)
      {
        String(decoding: decodedData, as: UTF8.self)
      } else {
        ""
      }
    }
    """
  }

  private func secretsDeclaration(properties: String) -> String {
    """
    \(access.rawValue) protocol Secrets: Sendable {
    \(properties)
    }
    """
  }

  private func shielderSecretsDeclaration(properties: String) -> String {
    """
    \(access.rawValue) struct ShielderSecrets: Secrets {
    \(properties)
    }
    """
  }
}
