//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation
import Testing
@testable import MinimalSharedServices

struct PreferencesStoreCodableTests {
  let store = PreferencesStoreSpy()
  let key = StoreKey<DummyCodable>(name: "test_key")

  @Test
  func writeReadDelete() throws {
    // write
    store.write(DummyCodable.dummy, forKey: key)
    #expect(store.writeInvocations.count == 1)
    #expect(store.readInvocations.isEmpty)
    #expect(store.deleteInvocations.isEmpty)

    let (anyData, keyName) = try #require(store.writeInvocations.first)
    let data = try #require(anyData as? Data)

    let readDummy = try JSONDecoder().decode(DummyCodable.self, from: data)
    #expect(readDummy == .dummy)
    #expect(keyName == "test_key")

    // read
    store.readReturnValue = DummyCodable.encodedVariants[0]
    let read = try #require(store.read(forKey: key))
    #expect(store.writeInvocations.count == 1)
    #expect(store.readInvocations.count == 1)
    #expect(store.deleteInvocations.isEmpty)
    #expect(read == .dummy)

    // delete
    store.delete(forKey: key)
    #expect(store.writeInvocations.count == 1)
    #expect(store.readInvocations.count == 1)
    #expect(store.deleteInvocations.count == 1)
  }
}
