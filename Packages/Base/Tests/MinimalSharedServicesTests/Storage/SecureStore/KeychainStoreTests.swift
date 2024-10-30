//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import MinimalSharedServices

@Suite(.tags(.keychain), .serialized)
struct KeychainStoreTests {
  let store = KeychainStore(kind: .password)

  init() async {
    await store.deleteSecret(for: "Bob")
    await store.deleteSecret(for: "Alice")
  }

  @Test
  func storeIsInitialyEmpty() async {
    await #expect(store.getSecret(for: "Bob") == nil)
  }

  @Test
  func setAndUpdate() async {
    await store.set(secret: "secretpassword", for: "Bob")
    await #expect(store.getSecret(for: "Bob") == "secretpassword")

    await store.set(secret: "newpassword", for: "Bob")
    await #expect(store.getSecret(for: "Bob") == "newpassword")
  }

  @Test
  func twoUsers() async {
    await store.set(secret: "secretpassword", for: "Bob")
    await store.set(secret: "supersecretpassword", for: "Alice")

    await #expect(store.getSecret(for: "Bob") == "secretpassword")
    await #expect(store.getSecret(for: "Alice") == "supersecretpassword")

    await store.deleteSecret(for: "Bob")
    await #expect(store.getSecret(for: "Alice") == "supersecretpassword")
  }
}
