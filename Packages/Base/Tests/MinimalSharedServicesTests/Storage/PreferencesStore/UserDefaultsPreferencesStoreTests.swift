//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation
import Testing
@testable import MinimalSharedServices

// MARK: - UserDefaultsPreferencesStoreTests

@Suite(.serialized)
struct UserDefaultsPreferencesStoreTests {
  let store: UserDefaultsPreferencesStore
  let defaults: UserDefaults

  init() {
    // swiftlint:disable:next force_unwrapping
    defaults = UserDefaults(suiteName: "TestStore")!
    store = UserDefaultsPreferencesStore(defaults: defaults)
    defaults.removeObject(forKey: "test_key")
  }

  // MARK: Basic types

  @Test
  func bool() {
    let key = StoreKey<Bool>.test()
    #expect(store.read(forKey: key) == false)

    store.write(true, forKey: key)
    #expect(store.read(forKey: key) == true)
    #expect(defaults.bool(forKey: key.name) == true)

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == false)
    #expect(defaults.bool(forKey: key.name) == false)
  }

  @Test
  func int() {
    let key = StoreKey<Int>.test()
    #expect(store.read(forKey: key) == 0)

    store.write(123, forKey: key)
    #expect(store.read(forKey: key) == 123)
    #expect(defaults.integer(forKey: key.name) == 123)

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == 0)
    #expect(defaults.integer(forKey: key.name) == 0)
  }

  @Test
  func float() {
    let key = StoreKey<Float>.test()
    #expect(store.read(forKey: key) == 0)

    store.write(123, forKey: key)
    #expect(store.read(forKey: key) == 123)
    #expect(defaults.float(forKey: key.name) == 123)

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == 0)
    #expect(defaults.float(forKey: key.name) == 0)
  }

  @Test
  func double() {
    let key = StoreKey<Double>.test()
    #expect(store.read(forKey: key) == 0)

    store.write(123, forKey: key)
    #expect(store.read(forKey: key) == 123)
    #expect(defaults.double(forKey: key.name) == 123)

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == 0)
    #expect(defaults.double(forKey: key.name) == 0)
  }

  @Test
  func string() {
    let key = StoreKey<String>.test()
    #expect(store.read(forKey: key) == nil)

    store.write("foo", forKey: key)
    #expect(store.read(forKey: key) == "foo")
    #expect(defaults.string(forKey: key.name) == "foo")

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == nil)
    #expect(defaults.string(forKey: key.name) == nil)
  }

  @Test
  func url() {
    let key = StoreKey<URL>.test()
    #expect(store.read(forKey: key) == nil)

    store.write(.example, forKey: key)
    #expect(store.read(forKey: key) == .example)
    #expect(defaults.url(forKey: key.name) == .example)

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == nil)
    #expect(defaults.url(forKey: key.name) == nil)
  }

  @Test
  func date() {
    let key = StoreKey<Date>.test()
    #expect(store.read(forKey: key) == nil)

    let date = Date()
    store.write(date, forKey: key)
    #expect(store.read(forKey: key) == date)
    #expect(defaults.object(forKey: key.name) as? Date == date)

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == nil)
    #expect(defaults.object(forKey: key.name) == nil)
  }

  @Test
  func data() {
    let key = StoreKey<Data>.test()
    #expect(store.read(forKey: key) == nil)

    let data = Data("foo".utf8)
    store.write(data, forKey: key)
    #expect(store.read(forKey: key) == data)
    #expect(defaults.data(forKey: key.name) == data)

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == nil)
    #expect(defaults.data(forKey: key.name) == nil)
  }

  @Test
  func stringArray() {
    let key = StoreKey<[String]>.test()
    #expect(store.read(forKey: key) == nil)

    store.write(["foo", "bar"], forKey: key)
    #expect(store.read(forKey: key) == ["foo", "bar"])
    #expect(defaults.stringArray(forKey: key.name) == ["foo", "bar"])

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == nil)
    #expect(defaults.stringArray(forKey: key.name) == nil)
  }

  // MARK: Optional

  @Test
  func optionalString() throws {
    let key = StoreKey<String?>.test()
    #expect(store.read(forKey: key) == nil)

    store.write("foo", forKey: key)
    #expect(store.read(forKey: key) == "foo")
    let data = Data("\"foo\"".utf8)
    #expect(defaults.data(forKey: key.name) == data)

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == nil)
    #expect(defaults.data(forKey: key.name) == nil)
  }

  // MARK: Codable

  @Test
  func codableDummy() throws {
    let key = StoreKey<DummyCodable>(name: "test_key")
    #expect(store.read(forKey: key) == nil)

    store.write(.dummy, forKey: key)

    #expect(store.read(forKey: key) == .dummy)
    let dummyData = try #require(defaults.data(forKey: key.name))
    #expect(DummyCodable.encodedVariants.contains(dummyData))

    store.delete(forKey: key)
    #expect(store.read(forKey: key) == nil)
    #expect(defaults.data(forKey: key.name) == nil)
  }
}

// MARK: - StoreKey + test

extension StoreKey {
  fileprivate static func test() -> Self {
    self.init(name: "test_key")
  }
}
