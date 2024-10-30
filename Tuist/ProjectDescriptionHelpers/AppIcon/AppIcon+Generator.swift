//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import AppKit
import SwiftUI

// MARK: - AppIcon.Generator

extension AppIcon {
  public enum Generator {
    @MainActor
    static func generateActorIsolated() throws {
      let prodFiles = try prodFiles()
      let fileManager = FileManager.default

      for env in AppEnvironment.allCases where env != .releaseProduction {
        let targetDirectory = targetDirectory(env: env)

        for prodImageURL in prodFiles.png {
          let prodImage = loadImageIgnoringDPI(from: prodImageURL)

          let data = View(baseImage: prodImage, text: env.postfix, textColor: env.overlayTextColor).nsImage.asPNGData
          let targetImageURL = targetDirectory.appending(path: prodImageURL.lastPathComponent)
          try fileManager.writeWithFolders(data: data, to: targetImageURL)
        }

        let targetContentsJSONURL = targetDirectory.appending(path: prodFiles.contentsJSON.lastPathComponent)
        try fileManager.copyItemWithFolders(fromURL: prodFiles.contentsJSON, to: targetContentsJSONURL)
      }
    }

    static func generate() {
      MainActor.assumeIsolated {
        // swiftlint:disable:next force_try
        try! generateActorIsolated()
      }
    }
  }
}

// MARK: - overlayTextColor

extension AppEnvironment {
  fileprivate var overlayTextColor: Color {
    switch self {
      case .debugSandbox: .purple
      case .debugStaging: .red
      case .releaseProduction: fatalError("Should not be executed")
    }
  }
}
