//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProjectDescription

public let entitlements = macOS

private let macOS: Entitlements = .dictionary([
  "com.apple.security.app-sandbox": true,
  "com.apple.security.network.client": true
])
