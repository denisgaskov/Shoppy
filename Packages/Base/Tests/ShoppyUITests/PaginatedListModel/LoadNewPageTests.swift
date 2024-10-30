//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import ShoppyUI

extension PaginatedListModelTests {
  @MainActor
  struct NewPage {
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
    func loadNextWithSuccess() async throws {
      sut.loadNextPage()

      #expect(sut.isLoading)

      let task = try #require(sut.currentTask)
      await Task.yield()
      provider.resume(page: ["foo2", "bar2"])
      _ = await task.result

      #expect(sut.elements == ["foo1", "bar1", "foo2", "bar2"])
      #expect(sut.hasLoadingError == false)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.hasNextPage == true)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadNextButLessThenExpected() async throws {
      sut.loadNextPage()

      #expect(sut.isLoading)

      let task = try #require(sut.currentTask)
      await Task.yield()
      provider.resume(page: ["foo2"])
      _ = await task.result

      #expect(sut.elements == ["foo1", "bar1", "foo2"])
      #expect(sut.hasLoadingError == false)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.hasNextPage == false)
      #expect(sut.isLoading == false)

      sut.loadNextPage()
      #expect(sut.currentTask == nil, "should not create new task")
    }

    @Test
    func loadNextWithError() async throws {
      sut.loadNextPage()

      #expect(sut.isLoading)

      let task = try #require(sut.currentTask)
      await Task.yield()
      provider.throwError()
      _ = await task.result

      #expect(sut.elements == ["foo1", "bar1"])
      #expect(sut.hasLoadingError == true)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.hasNextPage == true)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadTwiceSimultaneously() async throws {
      sut.loadNextPage()
      let task1 = try #require(sut.currentTask)

      sut.loadNextPage()
      let task2 = try #require(sut.currentTask)
      #expect(task1 == task2, "should not create new task")
    }
  }
}
