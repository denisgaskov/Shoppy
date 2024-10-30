//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

extension LogStore {
  public struct Entry: Sendable, Identifiable, Encodable {
    public enum Level: String, CaseIterable, Encodable, Sendable {
      case debug
      case info
      case notice
      case error
      case fault
      case undefined
    }

    public let id = UUID()
    public let date: Date
    public let message: String
    public let level: Level
    public let category: String
  }
}
