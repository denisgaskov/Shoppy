//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Factory

extension Container {
  public var executionContext: Factory<ExecutionContext> {
    self { FactoryExecutionContext() }
  }
}

// MARK: - ExecutionContext

public protocol ExecutionContext: Sendable {
  var isDebug: Bool { get }
  var isPreview: Bool { get }
  var isTest: Bool { get }
  var isSimulator: Bool { get }
}

// MARK: - FactoryExecutionContext

struct FactoryExecutionContext: ExecutionContext {
  private var factory: FactoryContext {
    FactoryContext.current
  }

  var isDebug: Bool { factory.isDebug }
  var isPreview: Bool { factory.isPreview }
  var isTest: Bool { factory.isTest }
  var isSimulator: Bool { factory.isSimulator }
}
