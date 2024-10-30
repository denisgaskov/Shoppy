//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation

// MARK: - LogEnvironment

struct LogEnvironment: PlainBootstrapAction {
  func bootstrap() {
    let container = Container.shared
    let logger = container.logger.bootstrap()
    let env = container.appEnvironment()
    let context = container.executionContext()
    logger.info(
      """
      App environment:
      Configuration: \(env.configuration.debugDescription)
      isDebug: \(context.isDebug)
      """
    )
  }
}

// MARK: - DebugDescription

extension AppConfiguration {
  fileprivate var debugDescription: String {
    switch self {
      case .sandbox: "Sandbox"
      case .production: "Production"
      case .staging: "Staging"
    }
  }
}
