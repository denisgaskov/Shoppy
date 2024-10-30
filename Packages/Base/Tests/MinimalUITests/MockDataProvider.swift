//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

@testable import MinimalUI

@MainActor
final class MockDataProvider {
  private var continuation: CheckedContinuation<[String], Error>!

  enum MockError: Error {
    case mock
  }

  func load(limit: Int, skip: Int) async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
    }
  }

  func resume(page: [String]) {
    continuation.resume(returning: page)
    continuation = nil
  }

  func throwError() {
    continuation.resume(throwing: MockError.mock)
    continuation = nil
  }

  func makeModel() -> PaginatedList.Model<String> {
    PaginatedList.Model(
      dataProvider: { [self] limit, skip in
        try await load(limit: limit, skip: skip)
      },
      pageSize: 2
    )
  }
}
