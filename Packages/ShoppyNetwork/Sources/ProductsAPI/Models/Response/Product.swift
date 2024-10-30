//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

extension ProductsAPI {
  public enum Response {
    struct ProductResponse: Decodable {
      let products: [Product]
    }

    public struct Product: Decodable, Sendable {
      public let title: String
      public let thumbnail: String
      public let price: Decimal
      public let stock: Int
    }
  }
}
