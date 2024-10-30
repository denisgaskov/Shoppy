//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import PackagePlugin

// MARK: - Plugin

@main
struct Plugin {
  private let formatters: [Formatter] = [SwiftLint(), SwiftFormat()]
}

// MARK: CommandPlugin

extension Plugin: CommandPlugin {
  func performCommand(context _: PluginContext, arguments _: [String]) async throws {
    assertionFailure("Swift Package Plugin is unsupported. Please use Xcode Command Plugin.")
  }
}

// MARK: XcodeCommandPlugin

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension Plugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments _: [String]) throws {
      for formatter in formatters {
        try formatter.format(context: context)
      }
    }
  }
#endif
