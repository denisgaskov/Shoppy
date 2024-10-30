//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import MinimalFoundation

struct AppConfigurationTests {
  let assertionFailureReporter = AssertionFailureReporterMock()

  init() {
    Container.shared.assertionFailureReporter.register { [assertionFailureReporter] in
      assertionFailureReporter
    }
  }

  @Test(arguments: [
    ("com.denisgaskov.minimal", AppConfiguration.production),
    ("com.denisgaskov.minimal.staging", .staging),
    ("com.denisgaskov.minimal.sandbox", .sandbox)
  ])
  func validBundleID(bundleIdentifier: String, expectedConfiguration: AppConfiguration) {
    let configuration = AppConfiguration(bundleIdentifier: bundleIdentifier)
    #expect(configuration == expectedConfiguration)
  }

  @Test
  func unknownBundleID() {
    let configuration = AppConfiguration(bundleIdentifier: "some.unknown.id")
    #expect(configuration == .production)
    #expect(assertionFailureReporter.invocations == ["Unexpected bundleIdentifier: some.unknown.id"])
  }
}
