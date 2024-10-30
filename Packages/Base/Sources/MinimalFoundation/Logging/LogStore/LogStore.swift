//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import OSLog

extension Container {
  public var logStore: Factory<LogStore.Store> {
    self { LogStore.DefaultStore() }
    #if DEBUG
      .onPreview { LogStore.PreviewStore() }
    #endif
  }
}

// MARK: - LogStore

public enum LogStore {
  public protocol Store: Sendable {
    func getLogEntries(period: TimeInterval, category: LogCategory?) async -> [Entry]
  }

  // MARK: DefaultStore

  struct DefaultStore: Store {
    private let appEnvironment = Container.shared.appEnvironment()

    func getLogEntries(period: TimeInterval, category: LogCategory?) async -> [LogStore.Entry] {
      do {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let date = Date(timeIntervalSinceNow: -period)
        let position = store.position(date: date)
        let predicate =
          if let category {
            NSPredicate(
              format: "(subsystem == %@) && (category == %@)",
              appEnvironment.bundleIdentifier,
              category.rawValue
            )
          } else {
            NSPredicate(format: "subsystem == %@", appEnvironment.bundleIdentifier)
          }
        return try store.getEntries(at: position, matching: predicate)
          .map { entry in
            try Task.checkCancellation()
            return Entry(osLog: entry)
          }
      } catch {
        return []
      }
    }
  }

  // MARK: PreviewStore

  #if DEBUG
    struct PreviewStore: Store {
      func getLogEntries(period _: TimeInterval, category _: LogCategory?) async -> [LogStore.Entry] {
        try? await Task.sleep(for: .seconds(1))
        return Seeds.LogEntry.levels
      }
    }
  #endif
}

// MARK: - Conversion

extension LogStore.Entry {
  init(osLog: OSLogEntry) {
    date = osLog.date
    message = osLog.composedMessage

    guard let osLog = osLog as? OSLogEntryLog else {
      level = .undefined
      category = "undefined"
      return
    }

    level = Level(osLog: osLog.level)
    category = osLog.category
  }
}

extension LogStore.Entry.Level {
  init(osLog: OSLogEntryLog.Level) {
    self =
      switch osLog {
        case .undefined: .undefined
        case .debug: .debug
        case .info: .info
        case .notice: .notice
        case .error: .error
        case .fault: .fault
        @unknown default: .undefined
      }
  }
}
