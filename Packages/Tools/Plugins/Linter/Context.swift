//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import PackagePlugin

// MARK: - Context

protocol Context {
  var repoRoot: URL { get }
  var pluginWorkDirectoryURL: URL { get }

  func tool(named: String) throws -> PluginContext.Tool
}

// MARK: - PluginContext + Context

extension PluginContext: Context {
  var repoRoot: URL {
    package.directoryURL.deletingLastPathComponent().deletingLastPathComponent()
  }
}

// MARK: - XcodeProjectPlugin + Context

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension XcodePluginContext: Context {
    var repoRoot: URL {
      xcodeProject.directoryURL
    }
  }
#endif
