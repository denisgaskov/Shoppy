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

  struct LoadInvocation: Equatable {
    let limit: Int
    let skip: Int
  }

  // swiftlint:disable:next implicitly_unwrapped_optional
  private var continuation: CheckedContinuation<[String], Error>!
  private(set) var loadInvocations: [LoadInvocation] = []

  func load(limit: Int, skip: Int) async throws -> [String] {
    loadInvocations.append(LoadInvocation(limit: limit, skip: skip))
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
    }
  }

  func resume(page: [String]) async {
    await Task.yield()
    continuation.resume(returning: page)
    continuation = nil
  }

  func throwError() async {
    await Task.yield()
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
