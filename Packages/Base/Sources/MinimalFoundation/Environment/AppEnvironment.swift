//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Factory
import Foundation

extension Container {
  public var appEnvironment: Factory<AppEnvironment> {
    self { DefaultAppEnvironment() }
      .onTest { MockAppEnvironment(appName: "Minimal (Unit Tests)") }
      .onPreview { MockAppEnvironment(appName: "Minimal (Preview)") }
  }
}

// MARK: - AppEnvironment

public protocol AppEnvironment: Sendable {
  var appName: String { get }
  var bundleIdentifier: String { get }
  var configuration: AppConfiguration { get }
}

// MARK: - DefaultAppEnvironment

struct DefaultAppEnvironment: AppEnvironment {
  let appName: String
  let bundleIdentifier: String
  let configuration: AppConfiguration

  init() {
    let bundle = Bundle.main

    if let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
      appName = displayName
    } else {
      assertionFailure("CFBundleDisplayName is nil.")
      appName = ""
    }

    if let bundleID = bundle.bundleIdentifier {
      bundleIdentifier = bundleID
    } else {
      assertionFailure("Bundle identifier is nil.")
      bundleIdentifier = ""
    }

    configuration = AppConfiguration(bundleIdentifier: bundleIdentifier)
  }
}

// MARK: - MockAppEnvironment

struct MockAppEnvironment: AppEnvironment {
  let appName: String
  let bundleIdentifier: String
  let configuration = AppConfiguration.sandbox

  init(appName: String) {
    self.appName = appName

    if let bundleID = Bundle.main.bundleIdentifier {
      bundleIdentifier = bundleID
    } else {
      assertionFailure("Bundle identifier is nil.")
      bundleIdentifier = ""
    }
  }
}
