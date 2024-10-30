//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

/// An entry point to `PaginatedList` component.
/// `PaginatedList` supports various types of pagination, error handling, and refresh features.
///
/// # Example usage
/// ```swift
/// PaginatedList.View(
///   dataProvider: { limit, skip in
///     ["foo\(skip + 1)", "bar \(skip + 2)"]
///   },
///   cellProvider: { element in
///     Text(element)
///   },
///   fetchConfiguration: .init(pageSize: 2)
/// )
/// ```
public enum PaginatedList {}

extension PaginatedList {
  public typealias DataProvider<Element> = (_ limit: Int, _ skip: Int) async throws -> [Element]

  public struct FetchConfiguration: Sendable {
    let pageSize: Int

    public static let `default` = Self(pageSize: 20)
  }
}

// MARK: - ContentState

extension PaginatedList {
  enum ContentState<Element> {
    case initialLoading
    case contentUnavailable(isError: Bool)
    case nonEmptyList([Element], hasNextPage: Bool)

    var elements: [Element] {
      if case .nonEmptyList(let array, _) = self {
        return array
      }

      return []
    }

    var hasNextPage: Bool {
      if case .nonEmptyList(_, let hasNextPage) = self {
        return hasNextPage
      }

      return false
    }

    /// `True` if loading of the first page has completed, regardless of success or failure; `False` otherwise.
    ///
    /// The `loadFirstPage` method can be called multiple times - on `onAppear`.
    /// For example, when the user returns from a child screen, we may want to avoid refreshing the screen,
    /// so we store and check this state.
    var didCompleteInitialLoading: Bool {
      if case .initialLoading = self {
        return false
      }

      return true
    }
  }
}

extension PaginatedList.ContentState: Equatable where Element: Equatable {}
