//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import MinimalUI

extension PaginatedListModelTests {
  @MainActor
  struct InitialState {
    let provider: MockDataProvider
    let sut: PaginatedList.Model<String>

    init() {
      let provider = MockDataProvider()
      sut = provider.makeModel()
      self.provider = provider
    }

    @Test
    func initialState() {
      #expect(sut.elements.isEmpty)
      #expect(sut.hasLoadingError == false)
      #expect(sut.showRefreshFailureAlert == false)
      #expect(sut.didTryToLoadFirstPage == false)
      #expect(sut.hasNextPage == false)
      #expect(sut.isLoading == false)
    }
  }
}
