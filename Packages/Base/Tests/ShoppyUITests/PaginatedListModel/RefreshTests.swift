//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import ShoppyUI

extension PaginatedListModelTests {
  @MainActor
  struct Refresh {
    let provider: MockDataProvider
    let sut: PaginatedList.Model<String>

    init() async throws {
      let provider = MockDataProvider()
      sut = provider.makeModel()
      self.provider = provider

      let task = try #require(sut.loadFirstPage())
      await provider.resume(page: ["foo1", "bar1"])
      _ = await task.result
    }

    @Test
    func refreshFirstPageWithSuccess() async throws {
      let task = try #require(sut.refresh())
      #expect(sut.isLoading)
      await provider.resume(page: ["foo2", "bar2"])
      _ = await task.result

      #expect(sut.content == .nonEmptyList(["foo2", "bar2"], hasNextPage: true))
      #expect(sut.hasLoadingError == false)
      #expect(sut.isLoading == false)

      #expect(provider.loadInvocations == [.init(limit: 2, skip: 0), .init(limit: 2, skip: 0)])
    }

    @Test
    func refreshFirstPageWithError() async throws {
      let task = try #require(sut.refresh())

      await provider.throwError()
      _ = await task.result

      #expect(sut.content == .nonEmptyList(["foo1", "bar1"], hasNextPage: true))
      #expect(sut.hasLoadingError == true)
      #expect(sut.isLoading == false)
    }

    @Test
    func refreshTwiceSimultaneously() async throws {
      let task1 = sut.refresh()
      let task2 = sut.refresh()

      #expect(task1 != nil)
      #expect(task2 != nil, "should create new task")
      #expect(task1 != task2)

      await Task.yield()
      #expect(provider.loadInvocations == [
        .init(limit: 2, skip: 0),
        .init(limit: 2, skip: 0),
        .init(limit: 2, skip: 0)
      ])
    }
  }
}
