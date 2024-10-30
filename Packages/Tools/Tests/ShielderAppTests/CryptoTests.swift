//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import ShielderApp

struct CryptoTests {
  @Test
  func generatesUniqueKeys() {
    let key1 = Crypto.genKey()
    let key2 = Crypto.genKey()
    #expect(key1 != key2)
  }
}
