//
//  Minimal
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
    "SampleClient",
    "Tools"
  ].map { .local(path: "Packages/\($0)") },
  settings: .settings(configurations: AppEnvironment.allConfigurations),
  targets: [
    .target(
      name: {
        RunOnce.run()
        return consts.appName
      }(),
      destinations: [.iPhone, .iPad, .mac],
      product: .app,
      // swiftformat:disable:next acronyms
      bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
      deploymentTargets: .multiplatform(iOS: consts.iOSVersion, macOS: consts.macOSVersion),
      infoPlist: .dictionary(infoPlist),
      sources: ["App/Sources/**"],
      resources: ["App/Resources/**"],
      entitlements: entitlements,
      scripts: [Scripts.Target.shielder],
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
