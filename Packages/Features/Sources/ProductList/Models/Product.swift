//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import ProductsAPI

// MARK: - Product

/// Represents a product with relevant information such as name, image, price, currency, and stock count.
struct Product {
  /// The name of the product.
  let name: String
  /// An optional URL to an image of the product.
  ///
  /// This URL may point to a remote image or a local image resource. If `nil`, no image is available for the product.
  let image: URL?
  /// The price of the product.
  ///
  /// Represented as a `Decimal` to maintain precision, especially for currency-related calculations.
  let price: Decimal
  /// The currency code associated with the product’s price.
  ///
  /// Uses the ISO 4217 currency code format (e.g., "USD" for U.S. Dollar, "EUR" for Euro).
  let currencyCode: String
  /// The number of items available in stock.
  ///
  /// This value is `0` if the product is out of stock.
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

// MARK: - Preview support

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
