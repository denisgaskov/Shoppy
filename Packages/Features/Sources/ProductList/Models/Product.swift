//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import ProductsAPI

struct Product {
  let name: String
  let image: URL?
  let price: Decimal
  let currencyCode: String
  let itemsInStockCount: Int
}

extension Product {
  init(product: ProductsAPI.Response.Product) {
    name = product.title
    image = URL(string: product.thumbnail)
    price = product.price
    // Since we don't have currency in API (but actualy we should!), for demo purposes we use USD.
    currencyCode = "USD"
    itemsInStockCount = product.stock
  }
}

// MARK: - Preview

#if DEBUG
  extension Product {
    static let preview = Product(
      name: "Lorem ipsum",
      image: .preview,
      price: 9.99,
      currencyCode: "USD",
      itemsInStockCount: 14
    )
  }
#endif
