//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProjectDescription

extension AppEnvironment {
  var schemeName: String {
    consts.appName + postfix
  }

  var scheme: Scheme {
    .scheme(
      name: schemeName,
      shared: true,
      buildAction: .buildAction(targets: [.target(consts.appName)]),
      testAction: isTestable ? .testPlans([consts.testPlan], configuration: configurationName) : nil,
      runAction: .runAction(configuration: configurationName),
      archiveAction: .archiveAction(configuration: configurationName),
      profileAction: .profileAction(configuration: configurationName),
      analyzeAction: .analyzeAction(configuration: configurationName)
    )
  }

  private var isTestable: Bool {
    switch self {
      case .debugSandbox: false
      case .debugStaging: true
      case .releaseProduction: false
    }
  }
}
