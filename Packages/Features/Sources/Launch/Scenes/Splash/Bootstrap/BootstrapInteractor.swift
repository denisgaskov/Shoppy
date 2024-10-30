//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import AsyncAlgorithms
import MinimalFoundation

extension Container {
  var bootstrapInteractor: Factory<BootstrapInteractor> {
    self {
      DefaultBootstrapInteractor(
        actions: [
          ActivateSandbox(),
          LogEnvironment(),
          SetupDeveloperTools()
        ]
      )
    }
    .cached
  }
}

// MARK: - BootstrapInteractor

protocol BootstrapInteractor {
  @MainActor
  func bootstrap() -> AsyncStream<Float>
}

// MARK: - DefaultBootstrapInteractor

final class DefaultBootstrapInteractor: BootstrapInteractor {
  private let logger = Container.shared.logger.bootstrap()

  private var isBootstrapCompleted = false

  private let actions: [BootstrapAction]

  init(actions: [BootstrapAction]) {
    self.actions = actions
  }

  func bootstrap() -> AsyncStream<Float> {
    if isBootstrapCompleted {
      return [1].async.eraseToStream()
    }

    isBootstrapCompleted = true

    return AsyncStream { continuation in
      Task {
        for (index, action) in actions.enumerated() {
          logger.debug("Will bootstrap \(type(of: action))")
          let previousCumulativeProgress = Float(index) / Float(actions.count)
          for await progress in action.bootstrap() {
            let partialProgress = progress / Float(actions.count)
            continuation.yield(previousCumulativeProgress + partialProgress)
          }
          logger.debug("Did bootstrap \(type(of: action))")
        }
        continuation.finish()
      }
    }
  }
}
