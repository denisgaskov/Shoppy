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
  fileprivate enum ListLoadingTrigger: String {
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

    // @Published is needed for `isLoading` computed property
    @Published
    private var currentTask: Task<Void, Error>?

    @Published
    private(set) var content: ContentState<Element> = .initialLoading

    @Published
    private(set) var hasLoadingError = false

    var isLoading: Bool {
      currentTask != nil
    }

    init(dataProvider: @escaping DataProvider<Element>, pageSize: Int) {
      self.dataProvider = dataProvider
      self.pageSize = pageSize
    }

    // MARK: - Actions

    @discardableResult
    func loadFirstPage() -> Task<Void, Error>? {
      guard !content.didCompleteInitialLoading, !isLoading else { return nil }
      return addTask(trigger: .firstPage)
    }

    @discardableResult
    func loadNextPage() -> Task<Void, Error>? {
      // If next page is still loading, do not interrupt it.
      guard content.hasNextPage, !isLoading else { return nil }
      return addTask(trigger: .newPage)
    }

    @discardableResult
    func refresh() -> Task<Void, Error> {
      // Can be called on:
      // 1. Pull-to-refresh
      // 2. 'Refresh' button tap from "ContentUnavailable" state
      // In both cases it's ok just to interrupt any previous task, and start refreshing again.
      currentTask?.cancel()

      return Task {
        // Wait until previous `currentTask` is cancelled and is set to nil (which is important for `isLoading`).
        await Task.yield()

        _ = await addTask(trigger: .refresh).result
      }
    }

    func cancelCurrentTask() {
      currentTask?.cancel()
      currentTask = nil
    }
  }
}

// MARK: - Private helpers

extension PaginatedList.Model {
  private func addTask(trigger: ListLoadingTrigger) -> Task<Void, Error> {
    logger.debug("Triggered loading: \(trigger.rawValue)")

    let newTask = Task<Void, Error> {
      do {
        let isRefresh = trigger == .refresh
        var oldElements = content.elements
        let newElements = try await dataProvider(pageSize, isRefresh ? 0 : oldElements.count)
        logger.debug("Loaded \(newElements.count) elements.")

        // If loading was successful, and if it was triggered by 'refresh', reset screen state.
        if isRefresh {
          page = 0
          oldElements.removeAll()
        }

        oldElements.append(contentsOf: newElements)

        content =
          if trigger == .firstPage, oldElements.isEmpty {
            .contentUnavailable(isError: false)
          } else {
            .nonEmptyList(oldElements, hasNextPage: newElements.count >= pageSize)
          }

        if content.hasNextPage {
          page += 1
        } else {
          logger.info("Loaded all data. Total: \(oldElements.count), last page: \(newElements.count).")
        }

        hasLoadingError = false
      } catch {
        logger.error("Loading failed: \(error)")

        if trigger == .firstPage {
          content = .contentUnavailable(isError: true)
        }

        if error is CancellationError {
          // Ignore CancellationErrors - don't show them in UI.
          throw error
        } else {
          hasLoadingError = true
        }
      }
      self.currentTask = nil
    }

    self.currentTask = newTask
    return newTask
  }
}
