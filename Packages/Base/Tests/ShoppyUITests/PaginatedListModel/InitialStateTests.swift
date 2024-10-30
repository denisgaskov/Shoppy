//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import ShoppyUI

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
      #expect(sut.content == .initialLoading)
      #expect(sut.hasLoadingError == false)
      #expect(sut.isLoading == false)
    }
  }
}
