//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

extension LogStore {
  public enum EntriesFormatter {
    public static func format(entries: [Entry]) -> String {
      entries
        .map { entry in
          [
            entry.date.ISO8601Format(),
            "::",
            entry.category,
            "::",
            entry.message
          ].joined(separator: " ")
        }
        .joined(separator: "\n")
    }
  }
}
