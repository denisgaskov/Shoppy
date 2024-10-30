//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

// MARK: - BootstrapAction

protocol BootstrapAction: Sendable {
  @MainActor
  func bootstrap() -> AsyncStream<Float>
}

// MARK: - PlainBootstrapAction

protocol PlainBootstrapAction: BootstrapAction {
  @MainActor
  func bootstrap()
}

extension PlainBootstrapAction {
  @MainActor
  func bootstrap() -> AsyncStream<Float> {
    AsyncStream { continuation in
      bootstrap()
      continuation.yield(1)
      continuation.finish()
    }
  }
}
