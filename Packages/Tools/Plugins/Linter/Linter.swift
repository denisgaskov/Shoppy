//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import PackagePlugin

// MARK: - Linter

protocol Linter {
  func lint(context: Context) throws -> Command
}

// MARK: - SwiftLint

struct SwiftLint: Linter {
  func lint(context: Context) throws -> Command {
    let arguments = [
      "lint",
      "--quiet",
      // We always pass all of the Swift source files in the target to the tool,
      // so we need to ensure that any exclusion rules in the configuration are
      // respected.
      "--force-exclude",
      "--cache-path", context.pluginWorkDirectoryURL.path(),
      "--config", context.repoRoot.appending(component: ".swiftlint.yml").path(),
      context.repoRoot.path()
    ]

    // We are not producing output files
    // and this is needed only to not include cache files into bundle
    let outputFilesDirectory = context.pluginWorkDirectoryURL.appending(component: "Output")

    return try .prebuildCommand(
      displayName: "SwiftLint",
      executable: context.tool(named: "swiftlint").url,
      arguments: arguments,
      outputFilesDirectory: outputFilesDirectory
    )
  }
}

// MARK: - SwiftFormat

struct SwiftFormat: Linter {
  func lint(context: Context) throws -> Command {
    var arguments = [
      "--lint",
      "--lenient",
      "--cache", context.pluginWorkDirectoryURL.path(),
      "--config", context.repoRoot.appending(component: ".swiftformat.yml").path(),
      context.repoRoot.path()
    ]

    // We are not producing output files
    // and this is needed only to not include cache files into bundle
    let outputFilesDirectory = context.pluginWorkDirectoryURL.appending(component: "Output")

    return try .prebuildCommand(
      displayName: "SwiftFormat",
      executable: context.tool(named: "swiftformat").url,
      arguments: arguments,
      outputFilesDirectory: outputFilesDirectory
    )
  }
}
