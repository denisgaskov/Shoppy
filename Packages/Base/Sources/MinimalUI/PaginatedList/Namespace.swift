//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

public enum PaginatedList {}

extension PaginatedList {
  public typealias DataProvider<Element> = (_ limit: Int, _ skip: Int) async throws -> [Element]

  public struct FetchConfiguration: Sendable {
    let pageSize: Int

    public static let `default` = Self(pageSize: 20)
  }
}
