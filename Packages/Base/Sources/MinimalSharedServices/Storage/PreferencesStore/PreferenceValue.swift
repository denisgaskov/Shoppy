//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

// MARK: - PreferenceValue

public protocol PreferenceValue {
  static func writer(defaults: UserDefaults) -> (Self, String) -> Void
  static func reader(defaults: UserDefaults) -> (String) -> Self?
}

extension PreferenceValue {
  public static func writer(defaults: UserDefaults) -> (Self, String) -> Void {
    { value, key in
      defaults.set(value, forKey: key)
    }
  }
}

// MARK: - Bool + PreferenceValue

extension Bool: PreferenceValue {
  public static func reader(defaults: UserDefaults) -> (String) -> Bool? {
    defaults.bool(forKey:)
  }
}

// MARK: - Int + PreferenceValue

extension Int: PreferenceValue {
  public static func reader(defaults: UserDefaults) -> (String) -> Int? {
    defaults.integer(forKey:)
  }
}

// MARK: - Float + PreferenceValue

extension Float: PreferenceValue {
  public static func reader(defaults: UserDefaults) -> (String) -> Float? {
    defaults.float(forKey:)
  }
}

// MARK: - Double + PreferenceValue

extension Double: PreferenceValue {
  public static func reader(defaults: UserDefaults) -> (String) -> Double? {
    defaults.double(forKey:)
  }
}

// MARK: - String + PreferenceValue

extension String: PreferenceValue {
  public static func reader(defaults: UserDefaults) -> (String) -> String? {
    defaults.string(forKey:)
  }
}

// MARK: - URL + PreferenceValue

extension URL: PreferenceValue {
  public static func writer(defaults: UserDefaults) -> (URL, String) -> Void {
    { value, key in
      defaults.set(value, forKey: key)
    }
  }

  public static func reader(defaults: UserDefaults) -> (String) -> URL? {
    defaults.url(forKey:)
  }
}

// MARK: - Date + PreferenceValue

extension Date: PreferenceValue {
  public static func reader(defaults: UserDefaults) -> (String) -> Date? {
    { key in
      defaults.object(forKey: key) as? Date
    }
  }
}

// MARK: - Data + PreferenceValue

extension Data: PreferenceValue {
  public static func reader(defaults: UserDefaults) -> (String) -> Data? {
    defaults.data(forKey:)
  }
}

// swiftformat:disable markTypes

// MARK: - [String] + PreferenceValue

extension [String]: PreferenceValue {
  public static func reader(defaults: UserDefaults) -> (String) -> [String]? {
    defaults.stringArray(forKey:)
  }
}

// not supported
// extension [PreferenceValue]: PreferenceValue {}
// extension [String: PreferenceValue]: PreferenceValue {}
