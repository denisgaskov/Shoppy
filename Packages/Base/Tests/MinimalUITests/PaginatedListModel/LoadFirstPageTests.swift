//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import MinimalUI

extension PaginatedListModelTests {
  @MainActor
  struct FirstPage {
    let provider: MockDataProvider
    let sut: PaginatedList.Model<String>

    init() {
      let provider = MockDataProvider()
      sut = provider.makeModel()
      self.provider = provider
    }

    @Test
    func loadWithSuccess() async throws {
      sut.loadFirstPage()
      let task = try #require(sut.currentTask)

      #expect(sut.isLoading)
      #expect(sut.didTryToLoadFirstPage == false)

      await Task.yield()
      provider.resume(page: ["foo", "bar"])
      _ = await task.result

      #expect(sut.elements == ["foo", "bar"])
      #expect(sut.hasLoadingError == false)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.didTryToLoadFirstPage == true)
      #expect(sut.hasNextPage == true)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadWithError() async throws {
      sut.loadFirstPage()
      let task = try #require(sut.currentTask)

      await Task.yield()
      provider.throwError()
      _ = await task.result

      #expect(sut.elements.isEmpty)
      #expect(sut.hasLoadingError == true)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.didTryToLoadFirstPage == true)
      #expect(sut.hasNextPage == false)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadButEmpty() async throws {
      sut.loadFirstPage()
      let task = try #require(sut.currentTask)

      await Task.yield()
      provider.resume(page: [])
      _ = await task.result

      #expect(sut.elements.isEmpty)
      #expect(sut.hasLoadingError == false)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.didTryToLoadFirstPage == true)
      #expect(sut.hasNextPage == false)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadButLessThenExpected() async throws {
      sut.loadFirstPage()
      let task = try #require(sut.currentTask)

      await Task.yield()
      provider.resume(page: ["foo"])
      _ = await task.result

      #expect(sut.elements == ["foo"])
      #expect(sut.hasLoadingError == false)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.didTryToLoadFirstPage == true)
      #expect(sut.hasNextPage == false)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadTwiceSimultaneously() async throws {
      sut.loadFirstPage()
      let task1 = try #require(sut.currentTask)

      sut.loadFirstPage()
      let task2 = try #require(sut.currentTask)
      #expect(task1 == task2, "should not create new task")
    }

    @Test
    func loadWithErrorAndRecover() async throws {
      sut.loadFirstPage()
      let task1 = try #require(sut.currentTask)

      await Task.yield()
      provider.throwError()
      _ = await task1.result

      Task {
        await sut.refresh()
      }
      try await Task.sleep(for: .milliseconds(10))

      let task2 = try #require(sut.currentTask)
      #expect(task1 != task2, "should create new task")

      provider.resume(page: ["foo"])
      _ = await task2.result

      #expect(sut.elements == ["foo"])
      #expect(sut.hasLoadingError == false)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.didTryToLoadFirstPage == true)
      #expect(sut.hasNextPage == false)
      #expect(sut.isLoading == false)
    }
  }
}
