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
