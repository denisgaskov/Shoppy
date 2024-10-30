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

      sut.loadFirstPage()
      let task = try #require(sut.currentTask)
      await Task.yield()
      provider.resume(page: ["foo1", "bar1"])
      _ = await task.result
    }

    @Test
    func refreshFirstPageWithSuccess() async throws {
      try await refresh()

      #expect(sut.isLoading)

      let task = try #require(sut.currentTask)
      await Task.yield()
      provider.resume(page: ["foo2", "bar2"])
      _ = await task.result

      #expect(sut.elements == ["foo2", "bar2"])
      #expect(sut.hasLoadingError == false)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.hasNextPage == true)
      #expect(sut.isLoading == false)
    }

    @Test
    func refreshFirstPageWithError() async throws {
      try await refresh()

      #expect(sut.isLoading)

      let task = try #require(sut.currentTask)
      await Task.yield()
      provider.throwError()
      _ = await task.result

      #expect(sut.elements == ["foo1", "bar1"])
      #expect(sut.hasLoadingError == true)
      #expect(sut.showRefreshFailureAlert == true)
      #expect(sut.hasNextPage == true)
      #expect(sut.isLoading == false)
    }

    @Test
    func refreshTwiceSimultaneously() async throws {
      try await refresh()
      let task1 = try #require(sut.currentTask)

      try await refresh()
      let task2 = try #require(sut.currentTask)

      #expect(task1 != task2, "should create new task")
    }

    private func refresh() async throws {
      Task {
        await sut.refresh()
      }
      try await Task.sleep(for: .milliseconds(10))
    }
  }
}
