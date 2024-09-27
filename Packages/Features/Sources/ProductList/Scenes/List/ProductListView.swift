//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import SwiftUI

public struct ProductListView: View {
  @StateObject
  private var model = ProductListViewModel()

  public var body: some View {
    List {
      ForEach(Array(model.products.enumerated()), id: \.offset) { index, product in
        ProductCard(product: product)
          .listRowSeparator(.hidden)
          .onAppear {
            if index == model.products.count - 1 {
              model.loadNextPage()
            }
          }
      }

      if !model.products.isEmpty, model.hasNextPage {
        Text("LOADING")
          .frame(maxWidth: .infinity, alignment: .center)
      }
    }
    .listStyle(.plain)
    .overlay {
      fullScreenProgressOverlay
    }
    .overlay {
      errorOverlay
    }
    .onAppear {
      model.loadFirstPageIfNeeded()
    }
    .refreshable {
      await model.refresh()
    }
    .navigationTitle("Products")
  }

  @ViewBuilder
  private var fullScreenProgressOverlay: some View {
    if model.products.isEmpty, model.isLoading {
      ProgressView()
    }
  }

  @ViewBuilder
  private var errorOverlay: some View {
    if model.isLoading {
      // Do not show any errors, if loading is in progress
      EmptyView()
    } else {
      switch model.error {
        case .emptyFirstPage:
          ContentUnavailableView("No products available", systemImage: "circle")
        case .firstPageLoadingFailed:
          ContentUnavailableView {
            Label("Failed to load products", systemImage: "xmark")
          } description: {
            Text("Try to load later")
          } actions: {
            Button {
              Task {
                await model.refresh()
              }
            } label: {
              HStack {
                Text("Refresh")

                if model.isLoading {
                  ProgressView()
                }
              }
            }
            .disabled(model.isLoading)
          }

        case .newPageLoadingFailed:
          // Pagination error is displayed as list item
          EmptyView()
        case .refreshFailed:
          // TODO: check
          EmptyView()
        case .none:
          EmptyView()
      }
    }
  }

  public init() {}
}

#Preview {
  NavigationStack {
    ProductListView()
  }
}
