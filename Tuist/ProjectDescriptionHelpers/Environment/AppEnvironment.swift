//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProjectDescription

// MARK: - AppEnvironment

public enum AppEnvironment: CaseIterable {
  case debugStaging
  case releaseProduction

  var postfix: String {
    switch self {
      case .debugStaging: "Staging"
      case .releaseProduction: ""
    }
  }
}

extension AppEnvironment {
  public static let allConfigurations = Self.allCases.map(\.configuration)
  public static let allSchemes = Self.allCases.map(\.scheme)
}
