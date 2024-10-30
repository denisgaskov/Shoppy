//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import MinimalFoundation

// MARK: - PreferencesStore

public protocol PreferencesStore: Sendable {
  func write<ValueType: PreferenceValue>(_ value: ValueType, forKey: StoreKey<ValueType>)
  func read<ValueType: PreferenceValue>(forKey: StoreKey<ValueType>) -> ValueType?
  func delete(forKey: StoreKey<some PreferenceValue>)
}

// MARK: PreferencesStore.SuiteName

extension PreferencesStore {
  public typealias SuiteName = String
}

extension Container {
  /// Factory to create ``PreferencesStore``.
  /// - Warning: Do not use this factory directly. Instead, declare a non-parametrised factory for your domain/module.
  ///
  /// Example:
  /// ===============================
  /// ```swift
  /// extension Container {
  ///  var notificationsSettings: Factory<PreferencesStore> {
  ///    self { self.preferencesStore("Notifications") }
  ///   }
  /// }
  /// ```
  public var preferencesStore: ParameterFactory<PreferencesStore.SuiteName?, PreferencesStore> {
    self { UserDefaultsPreferencesStore(defaults: UserDefaults(suiteName: $0) ?? .standard) }
  }
}

// MARK: - UserDefaultsPreferencesStore

struct UserDefaultsPreferencesStore: PreferencesStore {
  /// Per Apple docs, "The UserDefaults class is thread-safe."
  nonisolated(unsafe) let defaults: UserDefaults

  func write<ValueType: PreferenceValue>(_ value: ValueType, forKey key: StoreKey<ValueType>) {
    ValueType.writer(defaults: defaults)(value, key.name)
  }

  func read<ValueType: PreferenceValue>(forKey key: StoreKey<ValueType>) -> ValueType? {
    ValueType.reader(defaults: defaults)(key.name)
  }

  func delete(forKey key: StoreKey<some PreferenceValue>) {
    defaults.removeObject(forKey: key.name)
  }
}

// MARK: - PreferencesStore + Codable

extension PreferencesStore {
  func write<ValueType: Encodable>(_ value: ValueType, forKey key: StoreKey<ValueType>) {
    if let data = try? JSONEncoder().encode(value) {
      write(data, forKey: StoreKey<Data>(name: key.name))
    }
  }

  func read<ValueType: Decodable>(forKey key: StoreKey<ValueType>) -> ValueType? {
    guard
      let data = read(forKey: StoreKey<Data>(name: key.name)),
      let object = try? JSONDecoder().decode(ValueType.self, from: data)
    else {
      return nil
    }
    return object
  }

  func delete(forKey key: StoreKey<some Encodable>) {
    delete(forKey: StoreKey<Data>(name: key.name))
  }
}
