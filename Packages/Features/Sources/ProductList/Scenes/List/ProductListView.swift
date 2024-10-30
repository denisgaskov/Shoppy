//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import MinimalUI
import ProductsAPI
import SwiftUI

/// An entry point of `ProductList` feature.
/// Handles fetching products, pagination, refresh mechanism, and error handling.
public struct ProductListView: View {
  private let api = Container.shared.productsAPI()

  public var body: some View {
    PaginatedList.View(
      dataProvider: { limit, skip in
        try await api.getProducts(limit: limit, skip: skip)
          .map(Product.init(product:))
      },
      cellProvider: { item in
        ProductCard(product: item)
      }
    )
    .navigationTitle("Products")
  }

  public init() {}
}

#Preview {
  NavigationStack {
    ProductListView()
  }
}
