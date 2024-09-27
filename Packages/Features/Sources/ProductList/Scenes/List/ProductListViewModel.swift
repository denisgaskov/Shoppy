//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import ProductsAPI
import ShoppyNetwork
import SwiftUI

@MainActor
final class ProductListViewModel: ObservableObject {
  private let pageSize = 20
  private var page = 0

  @Published
  private var currentTask: Task<Void, Never>?

  private(set) var hasNextPage = true

  var isLoading: Bool {
    currentTask != nil
  }

  @Published
  private(set) var error: ListLoadingError?

  @Published
  private(set) var products: [Product] = []

  @Injected(\.productsAPI)
  private var productsAPI

  @Injected(\.logger.productList)
  private var logger

  /// Since we call this func on `onAppear`, it can be invoked multiple times (e. g. when pop the child screen)
  /// That's why we should check if it's our first invocation (or if there was an error before, or empty list has been returned)
  func loadFirstPageIfNeeded() {
    guard page == 0 else { return }
    currentTask?.cancel()
    addTask(trigger: .firstPage)
  }

  func loadNextPage() {
    logger.debug("Load next page triggered.")
    guard !isLoading else { return }
    addTask(trigger: .newPage)
  }

  /// This function is marked as `async` to keep `ProgressView` visible during loading.
  func refresh() async {
    logger.debug("Refresh triggered.")
    currentTask?.cancel()
    addTask(trigger: .refresh)
    _ = await currentTask?.result
  }

  private func loadPage() async throws(ShoppyNetwork.Error) {
    let newProducts = try await productsAPI
      .getProducts(limit: pageSize, skip: products.count)
      .map(Product.init(product:))

    products.append(contentsOf: newProducts)
    logger.debug("Loaded \(newProducts.count) products.")

    // Use '>=' instead of '=' if Backend occasionally returns more then 'pageSize' items.
    if newProducts.count >= pageSize {
      page += 1
    } else {
      logger.info("Loaded all data. Total: \(self.products.count), last page: \(newProducts.count).")
      hasNextPage = false
    }
  }

  private func addTask(trigger: ListLoadingTrigger) {
    currentTask = Task {
      do {
        try await loadPage()
        if trigger == .firstPage, products.isEmpty {
          self.error = .emptyFirstPage
        } else {
          self.error = nil
        }
      } catch {
        logger.error("Loading failed: \(error)")

        self.error = switch trigger {
          case .firstPage: .firstPageLoadingFailed
          case .newPage: .newPageLoadingFailed
          case .refresh: .refreshFailed
        }
      }

      currentTask = nil
    }
  }
}

extension ProductListViewModel {
  enum ListLoadingTrigger {
    case firstPage
    case newPage
    case refresh
  }

  enum ListLoadingError: Swift.Error {
    /// No items found on the first page
    case emptyFirstPage
    /// Initial load of the list failed
    case firstPageLoadingFailed
    /// Loading a new (paginated) page failed
    case newPageLoadingFailed
    /// Refresh of the list failed
    case refreshFailed
  }
}
