//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation

extension Container {
  public var passwordsStore: Factory<SecureStore> {
    self { KeychainStore(kind: .password) }
  }

  public var refreshTokensStore: Factory<SecureStore> {
    self { KeychainStore(kind: .refreshToken) }
  }
}

// MARK: - SecureStore

public protocol SecureStore: Sendable {
  func set(secret: String, for account: String) async
  func getSecret(for account: String) async -> String?
  func deleteSecret(for account: String) async

  func set(requireUserPresenceStatus: Bool, for account: String) async
}

// MARK: - KeychainStore

struct KeychainStore: SecureStore {
  private let logger = Container.shared.logger.keychain()

  let executor = KeychainQueryExecutor()
  let kind: KeychainQuery.Credential.Kind

  func set(secret: String, for account: String) async {
    let queryAdd = KeychainQuery.Credential.Add(account: account, kind: kind, data: Data(secret.utf8))
    do {
      try await executor.executeAdd(query: queryAdd)
    } catch .itemAlreadyExists {
      logger.debug("[\(kind.rawValue)] - Trying to add secret for \(account), but it already exists")
      let queryUpdate = KeychainQuery.Credential.Update(account: account, kind: kind, data: Data(secret.utf8))
      do {
        try await executor.executeUpdate(query: queryUpdate)
      } catch {
        logger.error("[\(kind.rawValue)] - Unhandled KeychainExecutor.executeUpdate error: \(error)")
      }
    } catch {
      logger.error("[\(kind.rawValue)] - Unhandled KeychainExecutor.executeAdd error: \(error)")
    }
  }

  func getSecret(for account: String) async -> String? {
    do {
      let query = KeychainQuery.Credential.Read(account: account, kind: kind)
      let data = try await executor.executeRead(query: query)
      return String(decoding: data, as: UTF8.self)
    } catch .notFound {
      return nil
    } catch {
      logger.error("[\(kind.rawValue)] - Unhandled KeychainExecutor.executeRead error: \(error)")
      return nil
    }
  }

  func deleteSecret(for account: String) async {
    do {
      let query = KeychainQuery.Credential.Delete(account: account, kind: kind)
      try await executor.executeDelete(query: query)
    } catch .notFound {
      logger.info("[\(kind.rawValue)] - No secret to be deleted for \(account)")
    } catch {
      logger.error("[\(kind.rawValue)] - Unhandled KeychainExecutor.executeDelete error: \(error)")
    }
  }

  func set(requireUserPresenceStatus: Bool, for account: String) async {
    guard let query = KeychainQuery.Credential.UpdateWithUserPresence(
      account: account,
      kind: kind,
      requireUserPresence: requireUserPresenceStatus
    ) else {
      logger.error("[\(kind.rawValue)] - Could not create UpdateWithUserPresence query")
      return
    }

    do {
      try await executor.executeUpdate(query: query)
    } catch {
      logger.error("[\(kind.rawValue)] - UpdateWithUserPresence error \(error)")
    }
  }
}
