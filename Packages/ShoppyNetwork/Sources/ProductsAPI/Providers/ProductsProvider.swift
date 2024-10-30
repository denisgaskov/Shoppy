//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import ShoppyNetwork

extension Container {
  public var productsAPI: Factory<ProductsAPI.Provider> {
    self { ProductsAPI.PreviewProvider() }
      .cached
      .onPreview {
        ProductsAPI.PreviewProvider()
      }
  }
}

// MARK: - Provider

extension ProductsAPI {
  public protocol Provider: Sendable {
    func getProducts(limit: Int, skip: Int) async throws -> [Response.Product]
  }
}

// MARK: - DefaultProvider

extension ProductsAPI {
  struct DefaultProvider: ProductsAPI.Provider {
    private let networkService = Container.shared.networkService()

    /// For simplicity, use hardcoded host.
    /// In real app, we should use xcconfig, xcsettings, or Swift code generation.
    private let host = "dummyjson.com"

    func getProducts(limit: Int, skip: Int) async throws -> [Response.Product] {
      let request = ShoppyNetwork.Request(
        method: .get,
        host: host,
        path: ["products"],
        queryItems: ["limit": "\(limit)", "skip": "\(skip)"]
      )

      let response: Response.ProductResponse = try await networkService.execute(request: request)
      return response.products
    }
  }
}

// MARK: - PreviewProvider

#if DEBUG
  extension ProductsAPI {
    struct PreviewProvider: ProductsAPI.Provider {
      func getProducts(limit: Int, skip: Int) async throws -> [Response.Product] {
        try await Task.sleep(for: .seconds(2))

        // 50% probability of error
        guard Bool.random() else {
          throw ShoppyNetwork.Error.unknown
        }

        return (0 ..< limit).map { index in
          let id = skip + index
          return Response.Product(
            title: "Lorem \(id)",
            thumbnail: "https://www.nordichq.com/wp-content/uploads/2023/03/Lightspeed-ecommerce-logo-686x1024.png",
            price: 19.99,
            stock: 10
          )
        }
      }
    }
  }
#endif
