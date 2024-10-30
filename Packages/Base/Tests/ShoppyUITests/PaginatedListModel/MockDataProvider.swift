//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

@testable import ShoppyUI

@MainActor
final class MockDataProvider {
  private enum MockError: Error {
    case mock
  }

  // swiftlint:disable:next implicitly_unwrapped_optional
  private var continuation: CheckedContinuation<[String], Error>!

  func load(limit _: Int, skip _: Int) async throws -> [String] {
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
