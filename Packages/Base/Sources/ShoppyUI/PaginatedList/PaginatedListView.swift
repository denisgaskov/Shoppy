//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ShoppyFoundation
import SwiftUI

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

        if model.hasNextPage {
          // If more pages are available, add a footer which is either 'Loading' or 'Error' (recoverable) state.
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
      .listStyle(.plain)
      .overlay {
        // If it's loading of the first page, show ProgressView
        if !model.didTryToLoadFirstPage, model.isLoading {
          ProgressView()
        }
      }
      .overlay {
        // If first page was loaded (with either empty content or error),
        // show ContentUnavailableView with 'Refresh' button.
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
            HStack {
              refreshButton

              // Just for demo purposes (as requested in task).
              // In real app, it's adviced not to use this UX.
              if model.isLoading {
                Button("Cancel") {
                  model.cancelCurrentTask()
                }
              }
            }
          }
        }
      }
      .refreshable {
        await model.refresh()
      }
      .onAppear {
        model.loadFirstPage()
      }
      .alert("Refresh failed", isPresented: $model.showRefreshFailureAlert) {
        // Do not provide any custom actions.
        // User can refresh again using same pull-to-refresh mechanism.
      }
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
    },
    fetchConfiguration: .init(pageSize: 30)
  )
}