//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import ShoppyFoundation

// MARK: - ListLoadingTrigger

extension PaginatedList.Model {
  /// Represents the different triggers for loading data in a paginated list.
  enum ListLoadingTrigger: String {
    /// Trigger for loading the first page of data.
    case firstPage
    /// Trigger for loading a new page of data, typically used for pagination when additional data is needed.
    case newPage
    /// Trigger for refreshing the existing data, reloading the list from the beginning.
    case refresh
  }
}

// MARK: - Model

extension PaginatedList {
  /// A `Model` subcomponent of `PaginatedList` feature.
  ///
  /// Contains and encapsulates business logic for:
  /// 1. loading first page - `loadFirstPage()`
  /// 2. loading next page (pagination) - `loadNextPage()`
  /// 3. refreshing from the beginning (pull-to-refresh) - `refresh()`
  /// 4. cancellation of current task - `cancelCurrentTask()`
  ///
  /// - Note: Additionally, has tests under `ShoppyUITests/PaginatedListModel`.
  /// When changing/adding functionality of `PaginatedList.Model`, UnitTests should be adjusted as well.
  @MainActor
  final class Model<Element: Sendable>: ObservableObject {
    private let logger = Container.shared.logger.paginatedList()
    private let dataProvider: DataProvider<Element>
    private let pageSize: Int
    private var page = 0

    @Published
    private(set) var currentTask: Task<Void, Never>?

    @Published
    private(set) var elements: [Element] = []

    @Published
    private(set) var hasLoadingError = false

    @Published
    var showRefreshFailureAlert = false

    /// `True` if loading of the first page has completed, regardless of success or failure; `False` otherwise.
    ///
    /// The `loadFirstPage` method can be called multiple times - on `onAppear`.
    /// For example, when the user returns from a child screen, we may want to avoid refreshing the screen,
    /// so we store and check this state.
    @Published
    private(set) var didTryToLoadFirstPage = false

    @Published
    private(set) var hasNextPage = false

    var isLoading: Bool {
      currentTask != nil
    }

    init(dataProvider: @escaping DataProvider<Element>, pageSize: Int) {
      self.dataProvider = dataProvider
      self.pageSize = pageSize
    }

    // MARK: - Actions

    func loadFirstPage() {
      guard !didTryToLoadFirstPage, !isLoading else { return }
      addTask(trigger: .firstPage)
    }

    func loadNextPage() {
      // If next page is still loading, do not interrupt it.
      guard hasNextPage, !isLoading else { return }
      addTask(trigger: .newPage)
    }

    func refresh() async {
      // Can be called on:
      // 1. Pull-to-refresh
      // 2. 'Refresh' button from full screen error state
      // In both cases it's ok just to interrupt any previous task, and start refreshing again.
      currentTask?.cancel()
      // Wait until previous `currentTask` is cancelled and is set to nil.
      await Task.yield()
      addTask(trigger: .refresh)
      // We use `async` signature and `await` for result, so SwiftUI's `refreshable` modifier can show running task.
      _ = await currentTask?.result
    }

    func cancelCurrentTask() {
      currentTask?.cancel()
      currentTask = nil
    }
  }
}

// MARK: - Private helpers

extension PaginatedList.Model {
  private func addTask(trigger: ListLoadingTrigger) {
    logger.debug("Triggered loading: \(trigger.rawValue)")
    currentTask = Task {
      do {
        let isRefresh = trigger == .refresh
        let newElements = try await dataProvider(pageSize, isRefresh ? 0 : elements.count)
        logger.debug("Loaded \(newElements.count) elements.")

        // If loading was successful, and if it was triggered by 'refresh', reset screen state.
        if isRefresh {
          page = 0
          elements.removeAll()
        }

        elements.append(contentsOf: newElements)

        // Use '>=' instead of '=', if API occasionally returns more then 'pageSize' items.
        if newElements.count >= pageSize {
          page += 1
          hasNextPage = true
        } else {
          logger.info("Loaded all data. Total: \(self.elements.count), last page: \(newElements.count).")
          hasNextPage = false
        }
        hasLoadingError = false
      } catch {
        logger.error("Loading failed: \(error)")

        // Ignore CancellationErrors and don't show them in UI.
        if !(error is CancellationError) {
          hasLoadingError = true
          if trigger == .refresh {
            showRefreshFailureAlert = true
          }
        }
      }

      if trigger == .firstPage {
        didTryToLoadFirstPage = true
      }

      currentTask = nil
    }
  }
}
