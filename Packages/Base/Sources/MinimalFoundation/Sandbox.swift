// swiftlint:disable:this file_name
//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Factory

#if DEBUG
  extension FactoryContext {
    public static let sandboxActivatedArg = "sandboxActivated"
  }

  extension FactoryModifying {
    /// Registers a factory closure to be used only when running in a Sandbox environment
    @discardableResult
    public func onSandbox(factory: @Sendable @escaping (P) -> T) -> Self {
      context(.arg(FactoryContext.sandboxActivatedArg), factory: factory)
    }
  }
#endif
