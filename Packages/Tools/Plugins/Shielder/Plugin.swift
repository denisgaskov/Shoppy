//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import PackagePlugin

// MARK: - Plugin

@main
struct Plugin {
  func fileExists(at url: URL) -> Bool {
    let path = url.path()
    guard FileManager.default.fileExists(atPath: path) else {
      let debugFileName = path.components(separatedBy: "/").last ?? path
      Diagnostics.error("File '\(debugFileName)' does not exist at path \(path)")
      return false
    }
    return true
  }

  func commands(context: Context) throws -> [Command] {
    let env = context.repoRoot.appending(component: ".env")
    let envLock = context.repoRoot.appending(component: ".env.lock")
    let output = context.pluginWorkDirectoryURL.appending(component: "ShielderGenerated.swift")
    guard fileExists(at: env), fileExists(at: envLock) else {
      return []
    }

    return try [
      .buildCommand(
        displayName: "Shielder",
        executable: context.tool(named: "ShielderApp").url,
        arguments: [
          env.path(),
          envLock.path(),
          output.path()
        ],
        inputFiles: [env, envLock],
        outputFiles: [output]
      )
    ]
  }
}

// MARK: BuildToolPlugin

extension Plugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target _: Target) throws -> [Command] {
    try commands(context: context)
  }
}

// MARK: XcodeBuildToolPlugin

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension Plugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target _: XcodeTarget) throws -> [Command] {
      try commands(context: context)
    }
  }
#endif
