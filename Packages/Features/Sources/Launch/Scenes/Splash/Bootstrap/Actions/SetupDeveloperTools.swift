//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import DeveloperTools
import MinimalFoundation

struct SetupDeveloperTools: PlainBootstrapAction {
  func bootstrap() {
    #if DEBUG
      let service = Container.shared.developerTools()
      service?.setupDebugMenu()
    #endif
  }
}
