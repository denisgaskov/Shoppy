//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

// MARK: - StoreKey

public struct StoreKey<DataType>: Sendable {
  public let name: String
}

// MARK: ExpressibleByStringLiteral

extension StoreKey: ExpressibleByStringLiteral {
  public typealias StringLiteralType = String

  public init(stringLiteral value: String) {
    self.init(name: value)
  }
}
