//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation
@preconcurrency import Security

// MARK: - KeychainQuery.Credential

extension KeychainQuery {
  enum Credential {
    enum Kind: String {
      case password
      case refreshToken
    }

    fileprivate static func service(ofKind kind: Kind) -> String {
      [
        Container.shared.appEnvironment().bundleIdentifier,
        kind.rawValue.capitalized
      ].joined(separator: ".")
    }
  }
}

extension KeychainQuery.Credential {
  // MARK: Add

  struct Add: KeychainQuery.Add {
    let account: String
    let kind: Kind
    let data: Data
    let title: String
    let description: String

    init(account: String, kind: Kind, data: Data) {
      self.account = account
      self.kind = kind
      self.data = data
      let appName = Container.shared.appEnvironment().appName
      title = "\(appName) app \(kind.rawValue)"
      description = "Internal \(kind.rawValue)"
    }

    var query: CFDictionary {
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: account,
        kSecAttrService: service(ofKind: kind),
        kSecAttrLabel: title,
        kSecAttrDescription: description,
        kSecValueData: data
      ] as CFDictionary
    }
  }

  // MARK: Read

  struct Read: KeychainQuery.Read {
    let account: String
    let kind: Kind

    var query: CFDictionary {
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: account,
        kSecAttrService: service(ofKind: kind),
        kSecReturnData: kCFBooleanTrue as Any,
        kSecMatchLimit: kSecMatchLimitOne
      ] as CFDictionary
    }
  }

  // MARK: Update

  struct Update: KeychainQuery.Update {
    let account: String
    let kind: Kind
    let data: Data

    var query: CFDictionary {
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: account,
        kSecAttrService: service(ofKind: kind)
      ] as CFDictionary
    }

    var updateQuery: CFDictionary {
      [
        kSecValueData: data
      ] as CFDictionary
    }
  }

  struct UpdateWithUserPresence: KeychainQuery.Update {
    let account: String
    let kind: Kind
    let access: SecAccessControl

    init?(account: String, kind: Kind, requireUserPresence: Bool) {
      self.account = account
      self.kind = kind

      let flags: SecAccessControlCreateFlags = requireUserPresence ? .userPresence : []
      guard let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, flags, nil) else {
        return nil
      }
      self.access = access
    }

    var query: CFDictionary {
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: account,
        kSecAttrService: service(ofKind: kind)
      ] as CFDictionary
    }

    var updateQuery: CFDictionary {
      [
        kSecAttrAccessControl: access
      ] as CFDictionary
    }
  }

  // MARK: Delete

  struct Delete: KeychainQuery.Delete {
    let account: String
    let kind: Kind

    var query: CFDictionary {
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: account,
        kSecAttrService: service(ofKind: kind)
      ] as CFDictionary
    }
  }
}
