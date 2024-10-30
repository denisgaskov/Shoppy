//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProjectDescription

public let infoPlist = app + launchScreen

private let app: [String: Plist.Value] = [:]

private let launchScreen: [String: Plist.Value] = [
  "UILaunchScreen": [
    "UIImageName": "LaunchImage",
    "UIImageRespectsSafeAreaInsets": true
  ]
]
