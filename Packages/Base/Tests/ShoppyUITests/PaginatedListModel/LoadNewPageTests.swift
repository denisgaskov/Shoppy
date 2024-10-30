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

      let task = try #require(sut.loadFirstPage())
      await provider.resume(page: ["foo1", "bar1"])
      _ = await task.result
    }

    @Test
    func loadNextWithSuccess() async throws {
      let task = try #require(sut.loadNextPage())

      #expect(sut.content == .nonEmptyList(["foo1", "bar1"], hasNextPage: true))
      #expect(sut.hasLoadingError == false)
      #expect(sut.isLoading == true)

      await provider.resume(page: ["foo2", "bar2"])
      _ = await task.result

      #expect(sut.content == .nonEmptyList(["foo1", "bar1", "foo2", "bar2"], hasNextPage: true))
      #expect(sut.hasLoadingError == false)
      #expect(sut.isLoading == false)
    }
    @Test
    func loadNextButLessThenExpected() async throws {
      let task = try #require(sut.loadNextPage())

      await provider.resume(page: ["foo2"])
      _ = await task.result

      #expect(sut.content == .nonEmptyList(["foo1", "bar1", "foo2"], hasNextPage: false))
      #expect(sut.hasLoadingError == false)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadNextWithError() async throws {
      let task = try #require(sut.loadNextPage())

      await provider.throwError()
      _ = await task.result

      #expect(sut.content == .nonEmptyList(["foo1", "bar1"], hasNextPage: true))
      #expect(sut.hasLoadingError == true)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadTwiceSimultaneously() async throws {
      let task1 = sut.loadNextPage()
      let task2 = sut.loadNextPage()

      #expect(task1 != nil)
      #expect(task2 == nil, "should not create new task")
    }
  }
}
