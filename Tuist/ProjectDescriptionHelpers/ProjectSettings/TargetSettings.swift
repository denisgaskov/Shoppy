//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProjectDescription

public let targetSettings: Settings = .settings(
  base: build + app + codeSigning,
  configurations: [],
  // App icon per each environment is configured in `Environment/Configuration.swift`
  defaultSettings: .recommended(excluding: ["ASSETCATALOG_COMPILER_APPICON_NAME"])
)

private let build: SettingsDictionary = [
  "GENERATE_INFOPLIST_FILE": true,
  "SWIFT_VERSION": "6.0",

  // Recommended non-tuist-default settings by Xcode
  "ENABLE_HARDENED_RUNTIME": true
]

private let app: SettingsDictionary = [
  "MARKETING_VERSION": .string(consts.appMarketingVersion),
  "CURRENT_PROJECT_VERSION": .string(buildNumberString)
]

private let codeSigning: SettingsDictionary = [
  "CODE_SIGN_IDENTITY": "Apple Development",
  "CODE_SIGN_STYLE": "Automatic",
  "DEVELOPMENT_TEAM": "2F488A453D"
]

/// Build number is dynamicaly computed as number of commits in the main branch
private var buildNumberString: String {
  shell("git rev-list main --count")
}
