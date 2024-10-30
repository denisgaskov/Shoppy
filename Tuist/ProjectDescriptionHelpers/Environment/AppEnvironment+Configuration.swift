//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProjectDescription

extension AppEnvironment {
  var configurationName: ConfigurationName {
    switch self {
      case .debugStaging: "Debug Staging"
      case .releaseProduction: "Release Production"
    }
  }

  var configurationSettings: SettingsDictionary {
    [
      "PRODUCT_BUNDLE_IDENTIFIER": .string(bundleIdentifier),
      "ASSETCATALOG_COMPILER_APPICON_NAME": .string(appIconName),
      "INFOPLIST_KEY_CFBundleDisplayName": .string(appMarketingName)
    ]
  }

  var configuration: Configuration {
    switch self {
      case .debugStaging: .debug(name: configurationName, settings: configurationSettings)
      case .releaseProduction: .release(name: configurationName, settings: configurationSettings)
    }
  }
}

// MARK: - Settings

extension AppEnvironment {
  private var bundleIdentifier: String {
    switch self {
      case .debugStaging: "com.denisgaskov.shoppy.staging"
      case .releaseProduction: "com.denisgaskov.shoppy"
    }
  }

  private var appIconName: String {
    "AppIcon" + postfix
  }

  private var appMarketingName: String {
    consts.appName + postfix
  }
}
