//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import PackagePlugin

// MARK: - Plugin

@main
struct Plugin {
  private let linters: [Linter] = [SwiftLint(), SwiftFormat()]
}

// MARK: BuildToolPlugin

extension Plugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target _: Target) throws -> [Command] {
    try linters.map { try $0.lint(context: context) }
  }
}

// MARK: XcodeBuildToolPlugin

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension Plugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target _: XcodeTarget) throws -> [Command] {
      try linters.map { try $0.lint(context: context) }
    }
  }
#endif
