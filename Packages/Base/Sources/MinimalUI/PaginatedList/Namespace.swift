//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

public enum PaginatedList {}

extension PaginatedList {
  typealias DataProvider<Element> = (_ limit: Int, _ skip: Int) async throws -> [Element]

  struct FetchConfiguration {
    let pageSize: Int

    static let `default` = FetchConfiguration(pageSize: 20)
  }

  struct ErrorsConfiguration {
    let noDataAvailable: LocalizedStringResource

    static let `default` = ErrorsConfiguration(
      noDataAvailable: "No data available"
    )
  }
}
