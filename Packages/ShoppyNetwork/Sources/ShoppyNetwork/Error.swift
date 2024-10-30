//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

extension ShoppyNetwork {
  public enum Error: Swift.Error {
    /// For simplcity, combines all types of HTTP protocol errors (e. g. 'server unreacheable', 'timeout', etc)
    case unknown
    case cancelled

    case invalidResponseType
    case invalidStatusCode(Int)
  }
}
