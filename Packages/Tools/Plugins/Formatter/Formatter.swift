//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import PackagePlugin

// MARK: - Formatter

protocol Formatter {
  func format(context: Context) throws
}

// MARK: - SwiftLint

struct SwiftLint: Formatter {
  func format(context: Context) throws {
    let arguments = [
      "lint",
      "--fix",
      "--quiet",
      // We always pass all of the Swift source files in the target to the tool,
      // so we need to ensure that any exclusion rules in the configuration are
      // respected.
      "--force-exclude",
      "--cache-path", context.pluginWorkDirectoryURL.path(),
      "--config", context.repoRoot.appending(component: ".swiftlint.yml").path(),
      context.repoRoot.path()
    ]

    let command = try ([context.tool(named: "swiftlint").url.path()] + arguments)
      .joined(separator: " ")
    shell(command)
  }
}

// MARK: - SwiftFormat

struct SwiftFormat: Formatter {
  func format(context: Context) throws {
    let arguments = [
      "--quiet",
      "--cache", "\(context.pluginWorkDirectoryURL.path())",
      "--config", context.repoRoot.appending(component: ".swiftformat.yml").path(),
      context.repoRoot.path()
    ]

    let command = try ([context.tool(named: "swiftformat").url.path()] + arguments)
      .joined(separator: " ")
    shell(command)
  }
}
