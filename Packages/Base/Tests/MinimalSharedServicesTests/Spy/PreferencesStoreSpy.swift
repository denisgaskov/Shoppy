//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
@testable import MinimalSharedServices

final class PreferencesStoreSpy: @unchecked Sendable, PreferencesStore {
  var writeInvocations: [(any PreferenceValue, String)] = []
  var readInvocations: [String] = []
  var deleteInvocations: [String] = []

  var readReturnValue: Data?

  func write<ValueType: PreferenceValue>(_ value: ValueType, forKey key: StoreKey<ValueType>) {
    writeInvocations.append((value, key.name))
  }

  func read<ValueType: PreferenceValue>(forKey key: StoreKey<ValueType>) -> ValueType? {
    readInvocations.append(key.name)
    return readReturnValue as? ValueType
  }

  func delete(forKey key: StoreKey<some PreferenceValue>) {
    deleteInvocations.append(key.name)
  }
}
