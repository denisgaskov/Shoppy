//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

#if DEBUG
  public struct DummyCodable: Codable, Equatable, Sendable {
    public static let dummy = Self(foo: 123, bar: "baz")
    public static let encodedVariants = [
      Data("{\"foo\":123,\"bar\":\"baz\"}".utf8),
      Data("{\"bar\":\"baz\",\"foo\":123}".utf8)
    ]

    public let foo: Int
    public let bar: String
  }
#endif
