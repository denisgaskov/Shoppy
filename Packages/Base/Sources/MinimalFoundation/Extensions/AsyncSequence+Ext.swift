//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

// Sourced from https://github.com/pointfreeco/swift-concurrency-extras/blob/main/Sources/ConcurrencyExtras/AsyncStream.swift

// MARK: - AsyncStream + Ext

extension AsyncStream {
  /// An `AsyncStream` that never emits and never completes unless cancelled.
  public static var never: Self {
    Self { _ in /* Do nothing */ }
  }

  /// An `AsyncStream` that never emits and completes immediately.
  public static var finished: Self {
    Self { $0.finish() }
  }

  /// Produces an `AsyncStream` from an `AsyncSequence` by consuming the sequence till it
  /// terminates, ignoring any failure.
  ///
  /// Useful as a kind of type eraser for live `AsyncSequence`-based dependencies.
  ///
  /// For example, your feature may want to subscribe to screenshot notifications. You can model
  /// this as a dependency client that returns an `AsyncStream`:
  ///
  /// ```swift
  /// struct ScreenshotsClient {
  ///   var screenshots: () -> AsyncStream<Void>
  ///   func callAsFunction() -> AsyncStream<Void> { self.screenshots() }
  /// }
  /// ```
  ///
  /// The "live" implementation of the dependency can supply a stream by erasing the appropriate
  /// `NotificationCenter.Notifications` async sequence:
  ///
  /// ```swift
  /// extension ScreenshotsClient {
  ///   static let live = Self(
  ///     screenshots: {
  ///       AsyncStream(
  ///         NotificationCenter.default
  ///           .notifications(named: UIApplication.userDidTakeScreenshotNotification)
  ///           .map { _ in }
  ///       )
  ///     }
  ///   )
  /// }
  /// ```
  ///
  /// While your tests can use `AsyncStream.makeStream` to spin up a controllable stream for tests:
  ///
  /// ```swift
  /// func testScreenshots() {
  ///   let screenshots = AsyncStream.makeStream(of: Void.self)
  ///
  ///   let model = withDependencies {
  ///     $0.screenshots = { screenshots.stream }
  ///   } operation: {
  ///     FeatureModel()
  ///   }
  ///
  ///   XCTAssertEqual(model.screenshotCount, 0)
  ///   screenshots.continuation.yield()  // Simulate a screenshot being taken.
  ///   XCTAssertEqual(model.screenshotCount, 1)
  /// }
  /// ```
  ///
  /// - Parameter sequence: An async sequence.
  public init<S: AsyncSequence>(_ sequence: S) where S.Element == Element, S: Sendable {
    let lock = NSLock()
    let iterator = UncheckedBox<S.AsyncIterator?>(wrappedValue: nil)
    self.init {
      lock.withLock {
        if iterator.wrappedValue == nil {
          iterator.wrappedValue = sequence.makeAsyncIterator()
        }
      }
      return try? await iterator.wrappedValue?.next()
    }
  }
}

// MARK: - AsyncSequence + Ext

extension AsyncSequence {
  /// Erases this async sequence to an async stream that produces elements till this sequence
  /// terminates (or fails).
  public func eraseToStream() -> AsyncStream<Element> where Self: Sendable {
    AsyncStream(self)
  }
}

// MARK: - UncheckedBox

final class UncheckedBox<Value>: @unchecked Sendable {
  var wrappedValue: Value

  init(wrappedValue: Value) {
    self.wrappedValue = wrappedValue
  }
}
