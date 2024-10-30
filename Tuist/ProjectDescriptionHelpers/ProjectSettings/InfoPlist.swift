//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProjectDescription

public let infoPlist = app + launchScreen + permissions + macOS

private let app: [String: Plist.Value] = [:]

private let launchScreen: [String: Plist.Value] = [
  "UILaunchScreen": [
    "UIImageName": "LaunchImage",
    "UIImageRespectsSafeAreaInsets": true
  ]
]

private let permissions: [String: Plist.Value] = [
  // swiftlint:disable:next line_length
  "NSFaceIDUsageDescription": "To secure your sensitive data, this app uses Face ID for authentication when accessing your stored information."
]

private let macOS: [String: Plist.Value] = [
  "LSApplicationCategoryType": "public.app-category.entertainment"
]
