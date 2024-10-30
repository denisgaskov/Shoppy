//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing

extension Tag {
  // FIXME: Fix Keychain tests on iOS Simulators
  /// Keychain tests do not run on iOS Simulators properly (missing entitlement). Should be fixed or skipped on CI.
  @Tag
  static var keychain: Self
}
