//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import ShoppyUI

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
      let task = try #require(sut.loadFirstPage())
      #expect(sut.isLoading)
      await provider.resume(page: ["foo", "bar"])
      _ = await task.result

      #expect(sut.content == .nonEmptyList(["foo", "bar"], hasNextPage: true))
      #expect(sut.hasLoadingError == false)
      #expect(sut.isLoading == false)
      #expect(provider.loadInvocations == [.init(limit: 2, skip: 0)])
    }

    @Test
    func loadWithError() async throws {
      let task = try #require(sut.loadFirstPage())
      await provider.throwError()
      _ = await task.result

      #expect(sut.content == .contentUnavailable(isError: true))
      #expect(sut.hasLoadingError == true)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadButEmpty() async throws {
      let task = try #require(sut.loadFirstPage())
      await provider.resume(page: [])
      _ = await task.result

      #expect(sut.content == .contentUnavailable(isError: false))
      #expect(sut.hasLoadingError == false)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadButLessThenExpected() async throws {
      let task = try #require(sut.loadFirstPage())
      await provider.resume(page: ["foo"])
      _ = await task.result

      #expect(sut.content == .nonEmptyList(["foo"], hasNextPage: false))
      #expect(sut.hasLoadingError == false)
      #expect(sut.isLoading == false)
    }

    @Test
    func loadTwiceSimultaneously() async throws {
      let task1 = sut.loadFirstPage()
      let task2 = sut.loadFirstPage()

      #expect(task1 != nil)
      #expect(task2 == nil, "should not create new task")

      await Task.yield()
      #expect(provider.loadInvocations == [.init(limit: 2, skip: 0)])
    }

    @Test
    func loadWithErrorAndRecover() async throws {
      let task1 = try #require(sut.loadFirstPage())
      await provider.throwError()
      _ = await task1.result

      let task2 = try #require(sut.refresh())
      #expect(task1 != task2, "should create new task")
      await provider.resume(page: ["foo"])
      _ = await task2.result

      #expect(sut.content == .nonEmptyList(["foo"], hasNextPage: false))
      #expect(sut.hasLoadingError == false)
      #expect(sut.isLoading == false)

      #expect(provider.loadInvocations == [.init(limit: 2, skip: 0), .init(limit: 2, skip: 0)])
    }
  }
}
