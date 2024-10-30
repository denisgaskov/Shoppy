//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import Launch

struct DefaultBootstrapInteractorTests {
  @Test
  func singleAction() async throws {
    let subscriber = DefaultBootstrapInteractorSubscriber(actionsCount: 1)
    await subscriber.subscribe()
    #expect(subscriber.progressElements.isEmpty)

    await subscriber.send(0.5, toActionAtIndex: 0)
    #expect(subscriber.progressElements == [0.5])

    await subscriber.send(0.7, toActionAtIndex: 0)
    #expect(subscriber.progressElements == [0.5, 0.7])

    await subscriber.send(1, toActionAtIndex: 0)
    #expect(subscriber.progressElements == [0.5, 0.7, 1])
    #expect(!subscriber.didTerminate)

    await subscriber.terminate(actionAtIndex: 0)
    #expect(subscriber.progressElements == [0.5, 0.7, 1])
    #expect(subscriber.didTerminate)
  }

  @Test
  func twoActions() async throws {
    let subscriber = DefaultBootstrapInteractorSubscriber(actionsCount: 2)
    await subscriber.subscribe()
    #expect(subscriber.progressElements.isEmpty)

    await subscriber.send(0.5, toActionAtIndex: 0)
    #expect(subscriber.progressElements == [0.25])

    await subscriber.send(1, toActionAtIndex: 0)
    await subscriber.terminate(actionAtIndex: 0)
    #expect(subscriber.progressElements == [0.25, 0.5])
    #expect(!subscriber.didTerminate)

    await subscriber.send(0.7, toActionAtIndex: 1)
    #expect(subscriber.progressElements == [0.25, 0.5, 0.85])
    #expect(!subscriber.didTerminate)

    await subscriber.send(1, toActionAtIndex: 1)
    await subscriber.terminate(actionAtIndex: 1)
    #expect(subscriber.progressElements == [0.25, 0.5, 0.85, 1])
    #expect(subscriber.didTerminate)
  }

  @Test
  func setupTwice() async throws {
    let subscriber = DefaultBootstrapInteractorSubscriber(actionsCount: 1)
    await subscriber.subscribe()
    await subscriber.send(1, toActionAtIndex: 0)

    #expect(subscriber.actions[0].bootstrapCallsCount == 1)

    await subscriber.subscribe()
    #expect(subscriber.actions[0].bootstrapCallsCount == 1)
  }

  @Test
  func setupTwiceSimultaneously() async throws {
    let subscriber = DefaultBootstrapInteractorSubscriber(actionsCount: 1)
    await subscriber.subscribe()
    await subscriber.subscribe()

    await subscriber.send(1, toActionAtIndex: 0)

    #expect(subscriber.actions[0].bootstrapCallsCount == 1)
  }
}
