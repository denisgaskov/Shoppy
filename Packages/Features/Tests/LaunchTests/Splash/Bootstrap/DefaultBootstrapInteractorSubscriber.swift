//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

@testable import Launch

// MARK: - DefaultBootstrapInteractorSubscriber

/// Helper class, which subscribes to `DefaultBootstrapInteractor` and manages it's `actions`.
final class DefaultBootstrapInteractorSubscriber: @unchecked Sendable {
  let actions: [MockBootstrapAction]
  private let interactor: DefaultBootstrapInteractor

  private(set) var progressElements: [Float] = []
  private(set) var didTerminate = false

  init(actionsCount: Int) {
    actions = Array(count: actionsCount, generator: MockBootstrapAction())
    interactor = DefaultBootstrapInteractor(actions: actions)
  }

  func subscribe() async {
    Task.detached {
      for await progress in await self.interactor.bootstrap() {
        self.progressElements.append(progress)
      }
      self.didTerminate = true
    }
    await sleep()
  }

  func send(_ value: Float, toActionAtIndex actionIndex: Int) async {
    actions[actionIndex].send(value)
    await sleep()
  }

  func terminate(actionAtIndex actionIndex: Int) async {
    actions[actionIndex].terminate()
    await sleep()
  }

  private func sleep() async {
    // swiftlint:disable:next force_try
    try! await Task.sleep(for: .milliseconds(50))
  }
}

// MARK: - MockBootstrapAction

final class MockBootstrapAction: BootstrapAction {
  // swiftlint:disable:next implicitly_unwrapped_optional
  private nonisolated(unsafe) var continuation: AsyncStream<Float>.Continuation!

  private(set) nonisolated(unsafe) var bootstrapCallsCount = 0

  func send(_ value: Float) {
    continuation.yield(value)
  }

  func terminate() {
    continuation.finish()
  }

  func bootstrap() -> AsyncStream<Float> {
    bootstrapCallsCount += 1
    return AsyncStream { continuation in
      self.continuation = continuation
    }
  }
}
