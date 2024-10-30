//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import MinimalSharedServices

extension Container {
  public var authService: Factory<AuthService> {
    self { DefaultAuthService() }
      .scope(.cached)
  }
}

// MARK: - AuthService

public protocol AuthService: Sendable {
  var isAuthorized: Bool { get async }

  func signIn(login: String, password: String) async throws

  func logout() async
}

// MARK: - DefaultAuthService

struct DefaultAuthService: AuthService {
  private static let defaultUserKey = "DefaultUserAccessToken"

  private let secretsStore = Container.shared.refreshTokensStore()
  private let logger = Container.shared.logger.authentication()

  var isAuthorized: Bool {
    get async {
      await secretsStore.getSecret(for: Self.defaultUserKey) != nil
    }
  }

  func signIn(login: String, password: String) async throws {
    let userToken = "\(login):\(password)"
    // TODO: Get user token using API request
    await secretsStore.set(secret: userToken, for: Self.defaultUserKey)
  }

  func logout() async {
    await secretsStore.deleteSecret(for: Self.defaultUserKey)
    // TODO: Reset cached (or session) scoped dependencies
  }
}
