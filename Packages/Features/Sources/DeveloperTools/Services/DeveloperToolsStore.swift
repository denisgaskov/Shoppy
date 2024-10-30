// swiftlint:disable:this file_name
//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation
import MinimalSharedServices

#if DEBUG
  extension UserDefaults {
    static var developerTools: UserDefaults? { UserDefaults(suiteName: "DeveloperTools") }
  }

  extension Container {
    var developerToolsStore: Factory<PreferencesStore> {
      self { self.preferencesStore("DeveloperTools") }
    }
  }

  extension StoreKey where DataType == Bool {
    static let shouldResetAndDelayLaunchScreen: Self = "shouldResetAndDelayLaunchScreen"
  }
#endif
