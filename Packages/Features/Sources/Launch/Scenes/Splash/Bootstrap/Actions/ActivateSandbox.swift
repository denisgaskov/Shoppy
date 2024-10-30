//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation

struct ActivateSandbox: PlainBootstrapAction {
  func bootstrap() {
    #if DEBUG
      if Container.shared.appEnvironment().configuration == .sandbox {
        FactoryContext.setArg(FactoryContext.sandboxActivatedArg, forKey: "Sandbox")
      }
    #endif
  }
}
