//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

/// Represents time intervals (in seconds) into the past from the current time.
///
/// We use `Int` as type for `RawValue`, because `AppStorage` supports only `Int` and `String` `RawRepresentable` types at the moment
enum LogPeriod: Int, Sendable, CaseIterable {
  case last10Minutes = 600 // 60 * 10
  case last24Hours = 86400 // 3600 * 24
}
