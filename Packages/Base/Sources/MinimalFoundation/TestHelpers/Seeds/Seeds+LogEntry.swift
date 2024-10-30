//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

#if DEBUG
  extension Seeds {
    public enum LogEntry {
      public static let `default` = LogStore.Entry(
        date: Date(),
        message: "Hello, world!",
        level: .debug,
        category: "MyLogCategory"
      )

      public static let levels: [LogStore.Entry] = LogStore.Entry.Level.allCases.enumerated().map { index, level in
        LogStore.Entry(
          date: Date().addingTimeInterval(-TimeInterval(index) * 3600),
          message: index.isMultiple(of: 2) ? "Long Message Text Message Text Message Text Message" : "Message text",
          level: level,
          category: "Category"
        )
      }
    }
  }
#endif
