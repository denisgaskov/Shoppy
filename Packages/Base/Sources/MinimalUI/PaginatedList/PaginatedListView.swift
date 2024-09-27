//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import SwiftUI
import MinimalFoundation

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
    var showErrorAlert = false

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
      guard !didTryToLoadFirstPage else {
        return
      }

      addTask(trigger: .firstPage) { [weak self] in
        self?.didTryToLoadFirstPage = true
      }
    }

    func loadNextPage() {
      guard !isLoading else { return }
      addTask(trigger: .newPage, completion: nil)
    }

    func refresh() async {
      currentTask?.cancel()
      addTask(trigger: .refresh, completion: nil)
      _ = await currentTask?.result
    }

    // MARK: - Private

    private func addTask(trigger: ListLoadingTrigger, completion: Callback?) {
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
        } catch {
          logger.error("Loading failed: \(error)")
          hasLoadingError = true
        }

        completion?()
        currentTask = nil
      }
    }
  }
}

// MARK: - View

extension PaginatedList {
  struct View<Element: Sendable, Cell: SwiftUI.View>: SwiftUI.View {
    @StateObject
    private var model: Model<Element>

    @Environment(\.refresh)
    private var refresh

    private let cellProvider: (Element) -> Cell
    private let errorsConfiguration: ErrorsConfiguration

    var body: some SwiftUI.View {
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
          if model.hasLoadingError {
            Button("Error happened. Retry?") {
              model.loadNextPage()
            }
          } else if model.isLoading {
            ProgressView()
              .frame(maxWidth: .infinity, alignment: .center)
          }
        }
      }
      .overlay {
        if !model.didTryToLoadFirstPage, model.isLoading {
          ProgressView()
        }
      }
      .overlay {
        if model.didTryToLoadFirstPage, model.elements.isEmpty {
          ContentUnavailableView {
            if model.hasLoadingError {
              Text("Failed to load data")
            } else {
              Text(errorsConfiguration.noDataAvailable)
            }
          } description: {
            Text("Try again later")
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
      .alert("Refresh failed", isPresented: $model.showErrorAlert) {
        Button("Try again") {
          Task {
            await refresh?()
          }
        }

        Button("OK", role: .cancel) {}
      }
    }

    private var refreshButton: some SwiftUI.View {
      Button {
        Task {
          await refresh?()
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

    init(
      dataProvider: @escaping DataProvider<Element>,
      cellProvider: @escaping (Element) -> Cell,
      fetchConfiguration: FetchConfiguration = .default,
      errorsConfiguration: ErrorsConfiguration = .default
    ) {
      self._model = .init(wrappedValue: .init(
        dataProvider: dataProvider,
        pageSize: fetchConfiguration.pageSize
      ))
      self.cellProvider = cellProvider
      self.errorsConfiguration = errorsConfiguration
    }
  }
}

#Preview {
  PaginatedList.View(
    dataProvider: { limit, skip in
      try await Task.sleep(for: .seconds(1))
      return (0..<limit).map { index in
        "Item \(skip + index)"
      }
    },
    cellProvider: { title in
      Text(title)
    },
    fetchConfiguration: .init(pageSize: 30)
  )
}
