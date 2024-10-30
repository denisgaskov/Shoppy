// swiftlint:disable:this file_name
//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Factory

#if DEBUG
  extension Container {
    var assertionFailureReporter: Factory<AssertionFailureReporter> {
      self { DefaultAssertionFailureReporter() }
        .cached
    }
  }

  /// A DI-wrapped `assertionFailure` function. Use it when you need to swap it in Unit Tests
  /// - Parameter message: A string to print in a playground or -Onone build. The default is an empty string.
  public func assertionFailure(
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let reporter = Container.shared.assertionFailureReporter()
    reporter.assertionFailure(message(), file: file, line: line)
  }

  // MARK: - AssertionFailureReporter

  protocol AssertionFailureReporter {
    func assertionFailure(_ message: @autoclosure () -> String, file: StaticString, line: UInt)
  }

  // MARK: - DefaultAssertionFailureReporter

  struct DefaultAssertionFailureReporter: AssertionFailureReporter {
    func assertionFailure(_ message: @autoclosure () -> String, file: StaticString, line: UInt) {
      Swift.assertionFailure(message(), file: file, line: line)
    }
  }

  // MARK: - AssertionFailureReporterMock

  final class AssertionFailureReporterMock: Sendable, AssertionFailureReporter {
    private(set) nonisolated(unsafe) var invocations: [String] = []

    func assertionFailure(_ message: @autoclosure () -> String, file _: StaticString, line _: UInt) {
      invocations.append(message())
    }
  }
#endif
