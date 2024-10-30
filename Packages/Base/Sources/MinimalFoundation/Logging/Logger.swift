//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import OSLog

// MARK: - LogCategory

public enum LogCategory: String, Sendable, CaseIterable {
  case authentication
  case bootstrap
  case keychain
  case sharedServices
  case network
}

// MARK: - Container + Logger

/// We can't use keypath for static properties (https://github.com/swiftlang/swift/issues/57696),
/// so enum as a namespace. As a workaround, a computed property which returns a struct is used.
/// There's no significant performance drawback expected, as this struct does not contain any data.
extension Container {
  public struct Logger: Sendable {
    public var authentication: Factory<os.Logger> {
      Container { os.Logger(category: .authentication) }
    }

    public var bootstrap: Factory<os.Logger> {
      Container { os.Logger(category: .bootstrap) }
    }

    public var keychain: Factory<os.Logger> {
      Container { os.Logger(category: .keychain) }
    }

    public var sharedServices: Factory<os.Logger> {
      Container { os.Logger(category: .sharedServices) }
    }

    public var network: Factory<os.Logger> {
      Container { os.Logger(category: .network) }
    }
  }

  public var logger: Logger { Logger() }
}

// MARK: - Logger + init

extension Logger {
  fileprivate init(category: LogCategory) {
    let bundleIdentifier = Container.shared.appEnvironment().bundleIdentifier
    self.init(subsystem: bundleIdentifier, category: category.rawValue)
  }
}
