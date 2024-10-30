//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ShoppyFoundation
import SwiftUI

// MARK: - View

extension PaginatedList {
  /// A `View` subcomponent of `PaginatedList` feature.
  public struct View<Element: Sendable, Cell: SwiftUI.View>: SwiftUI.View {
    @StateObject
    private var model: Model<Element>
    @State
    private var hasRefreshError = false
    private let cellProvider: (Element) -> Cell

    public var body: some SwiftUI.View {
      Group {
        switch model.content {
          case .initialLoading:
            ProgressView()
          case .contentUnavailable(let isError):
            contentUnavailableView(isError: isError)
          case .nonEmptyList(let array, let hasNextPage):
            elementsList(elements: array, hasNextPage: hasNextPage)
        }
      }
      .refreshable {
        _ = await model.refresh().result
        hasRefreshError = model.hasLoadingError
      }
      .onAppear {
        model.loadFirstPage()
      }
      .alert("Refreshing failed", isPresented: $hasRefreshError) {
        Button("OK", role: .cancel) {}
      } message: {
        Text("Use pull-to-refresh to try again later.")
      }
    }

    // MARK: Init

    /// Initializes a `PaginatedList.View`
    /// - Parameters:
    ///   - dataProvider: Closure, which takes 2 parameters: `limit` and `skip`, and returns an array of `Element` objects.
    ///   E. g., models for `cellProvider`.
    ///   - cellProvider: Closure, which takes `Element` and returns `Cell` - a View.
    ///   - fetchConfiguration: Additional configuration for fetching. Optional.
    public init(
      dataProvider: @escaping DataProvider<Element>,
      cellProvider: @escaping (Element) -> Cell,
      fetchConfiguration: FetchConfiguration = .default
    ) {
      _model = .init(wrappedValue: .init(
        dataProvider: dataProvider,
        pageSize: fetchConfiguration.pageSize
      ))
      self.cellProvider = cellProvider
    }
  }
}

// MARK: - ContentUnavailable

extension PaginatedList.View {
  /// A custom ContentUnavailableView.
  ///
  /// This View is shown when:
  /// 1. First page is empty: e. g. no products on the server.
  /// 2. Loading of first page ended with an error.
  @ViewBuilder
  private func contentUnavailableView(isError: Bool) -> some SwiftUI.View {
    ContentUnavailableView {
      if isError {
        Text("Oops! Something Went Wrong")
      } else {
        Text("No data available")
      }
    } description: {
      if isError {
        Text("We couldn’t load the content. Please check your internet connection or try again later")
      } else {
        Text("It looks like there’s nothing to display here right now. Try refreshing later for updates")
      }
    } actions: {
      contentUnavailableActions
    }
  }

  /// Set of two buttons: "Refresh" and "Cancel", arranged vertically.
  ///
  /// Rules:
  /// - `Refresh` button becomes disabled when loading.
  /// - `ProgressView` is added near "Refresh" button when loading.
  /// - `Cancel` button is hidden when is not loading.
  private var contentUnavailableActions: some SwiftUI.View {
    VStack {
      HStack {
        Button("Refresh", systemImage: "arrow.clockwise.circle") {
          model.refresh()
        }
        .disabled(model.isLoading)

        ProgressView()
          .opacity(model.isLoading ? 1 : 0)
      }

      Button("Cancel") {
        model.cancelCurrentTask()
      }
      .opacity(model.isLoading ? 1 : 0)
    }
  }
}

// MARK: - ElementsList

extension PaginatedList.View {
  @ViewBuilder
  private func elementsList(elements: [Element], hasNextPage: Bool) -> some SwiftUI.View {
    List {
      ForEach(Array(elements.enumerated()), id: \.offset) { index, element in
        cellProvider(element)
          .listRowSeparator(.hidden)
          .onAppear {
            if index == elements.count - 1 {
              model.loadNextPage()
            }
          }
      }

      if hasNextPage {
        loadingFooter
      }
    }
    .listStyle(.plain)
  }

  /// Loading footer, which is attached when first page is downloaded, and more pages are available.
  ///
  /// If next page is still loading, shows non-interactive "Loading" text.
  /// If next page loading ended with an error, shows "Retry" button, which attempts to load next page again.
  @ViewBuilder
  private var loadingFooter: some SwiftUI.View {
    // If more pages are available, add a footer which is either 'Loading' or recoverable 'Error' state.
    Group {
      if model.isLoading {
        Text("Loading...")
      } else if model.hasLoadingError {
        Button("Error happened. Retry?") {
          model.loadNextPage()
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .listRowSeparator(.hidden)
  }
}

// MARK: - Preview

#Preview {
  PaginatedList.View(
    dataProvider: { limit, skip in
      try await Task.sleep(for: .seconds(1))

      enum MockError: Error { case mock }
      // 50% probability of error
      guard Bool.random() else {
        throw MockError.mock
      }
      return (0 ..< limit).map { index in
        "Item \(skip + index)"
      }
    },
    cellProvider: { title in
      Text(title)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.cardBackground)
        }
    },
    fetchConfiguration: .init(pageSize: 30)
  )
}
