//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import SwiftUI

enum ListLoadingTrigger: String {
  case firstPage
  case newPage
  case refresh
}

// MARK: - Model

extension PaginatedList {
  @MainActor
  final class Model<Element: Sendable>: ObservableObject {
    private let logger = Container.shared.logger.paginatedList()
    private let dataProvider: DataProvider<Element>
    private let pageSize: Int
    private var page = 0

    @Published
    private var currentTask: Task<Void, Never>?

    @Published
    private(set) var elements: [Element] = []

    @Published
    private(set) var hasLoadingError = false

    @Published
    var showRefreshFailureAlert = false

    @Published
    private(set) var didTryToLoadFirstPage = false

    @Published
    private(set) var hasNextPage = true

    var isLoading: Bool {
      currentTask != nil
    }

    init(
      dataProvider: @escaping DataProvider<Element>,
      pageSize: Int
    ) {
      self.dataProvider = dataProvider
      self.pageSize = pageSize
    }

    func loadFirstPage() {
      // `loadFirstPage` can be invoked multiple times.
      // E. g. we don't want to refresh the screen when used comes back from child screen,
      // so store and check this state.
      guard !didTryToLoadFirstPage else {
        return
      }

      addTask(trigger: .firstPage)
    }

    func loadNextPage() {
      guard !isLoading else { return }
      addTask(trigger: .newPage)
    }

    func refresh() async {
      currentTask?.cancel()
      // Wait when `currentTask` is completely cancelled and is set to nil
      await Task.yield()
      addTask(trigger: .refresh)
      _ = await currentTask?.result
    }

    // MARK: - Private

    private func addTask(trigger: ListLoadingTrigger) {
      logger.debug("Triggered loading: \(trigger.rawValue)")
      currentTask = Task {
        do {
          let isRefresh = trigger == .refresh
          let newElements = try await dataProvider(pageSize, isRefresh ? 0 : elements.count)
          if isRefresh {
            page = 0
            elements.removeAll()
          }

          elements.append(contentsOf: newElements)
          logger.debug("Loaded \(newElements.count) elements.")

          // Use '>=' instead of '=', if API occasionally returns more then 'pageSize' items.
          if newElements.count >= pageSize {
            page += 1
          } else {
            logger.info("Loaded all data. Total: \(self.elements.count), last page: \(newElements.count).")
            hasNextPage = false
          }
          hasLoadingError = false
        } catch {
          logger.error("Loading failed: \(error)")

          // Ignore CancellationErrors, and don't show them in UI.
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
}

// MARK: - View

extension PaginatedList {
  public struct View<Element: Sendable, Cell: SwiftUI.View>: SwiftUI.View {
    @StateObject
    private var model: Model<Element>

    private let cellProvider: (Element) -> Cell

    public var body: some SwiftUI.View {
      List {
        ForEach(Array(model.elements.enumerated()), id: \.offset) { index, element in
          cellProvider(element)
            .listRowSeparator(.hidden)
            .onAppear {
              if index == model.elements.count - 1 {
                model.loadNextPage()
              }
            }
        }

        if !model.elements.isEmpty, model.hasNextPage {
          Group {
            if model.isLoading {
              Text("Loading...")
                .listRowSeparator(.hidden)
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
      .listStyle(.plain)
      .overlay {
        if !model.didTryToLoadFirstPage, model.isLoading {
          ProgressView()
        }
      }
      .overlay {
        if model.didTryToLoadFirstPage, model.elements.isEmpty {
          ContentUnavailableView {
            if model.hasLoadingError {
              Text("Oops! Something Went Wrong")
            } else {
              Text("No data available")
            }
          } description: {
            if model.hasLoadingError {
              Text("We couldn’t load the content. Please check your internet connection or try again later")
            } else {
              Text("It looks like there’s nothing to display here right now. Try refreshing later for updates")
            }
          } actions: {
            refreshButton
          }
        }
      }
      .refreshable {
        await model.refresh()
      }
      .onAppear {
        model.loadFirstPage()
      }
      .alert("Refresh failed", isPresented: $model.showRefreshFailureAlert) { /* No custom actions */ }
    }

    private var refreshButton: some SwiftUI.View {
      Button {
        Task {
          await model.refresh()
        }
      } label: {
        HStack {
          Image(systemName: "arrow.clockwise.circle")
          Text("Refresh")
          if model.isLoading {
            ProgressView()
          }
        }
      }
      .disabled(model.isLoading)
    }

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
    },
    fetchConfiguration: .init(pageSize: 30)
  )
}
