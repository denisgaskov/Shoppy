//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

let options = Project.Options.options(
  automaticSchemesOptions: .disabled,
  disableBundleAccessors: true,
  disableSynthesizedResourceAccessors: true
)

let project = Project(
  name: consts.appName,
  options: options,
  packages: [
    "Base",
    "Features",
    "ShoppyNetwork",
    "Tools"
  ].map { .local(path: "Packages/\($0)") },
  settings: .settings(configurations: AppEnvironment.allConfigurations),
  targets: [
    .target(
      name: {
        RunOnce.run()
        return consts.appName
      }(),
      destinations: .iOS,
      product: .app,
      // swiftformat:disable:next acronyms
      bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
      deploymentTargets: .iOS(consts.iOSVersion),
      infoPlist: .dictionary(infoPlist),
      sources: ["App/Sources/**"],
      resources: ["App/Resources/**"],
      dependencies: [
        .package(product: "Root", type: .runtime),
        .package(product: "Linter", type: .plugin)
      ],
      settings: targetSettings,
      // Tuist does not include ".xctestplan" files in Xcode project.
      // This is a workaround to forcefully show them in Xcode project.
      additionalFiles: [.glob(pattern: consts.testPlan)]
    )
  ],
  schemes: AppEnvironment.allSchemes
)
