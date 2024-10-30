//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

// MARK: - AppConfiguration

public enum AppConfiguration: Sendable {
  case sandbox
  case production
  case staging

  init(bundleIdentifier: String) {
    switch bundleIdentifier {
      case "com.denisgaskov.minimal":
        self = .production
      case "com.denisgaskov.minimal.sandbox":
        self = .sandbox
      case "com.denisgaskov.minimal.staging":
        self = .staging
      default:
        assertionFailure("Unexpected bundleIdentifier: \(bundleIdentifier)")
        self = .production
    }
  }
}
