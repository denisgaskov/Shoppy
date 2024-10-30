//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import Numerics
import Testing
@testable import MinimalFoundation

struct AsyncStreamFakeProgressTests {
  @Test
  func testDurationAlgoIsCorrect() {
    let totalDuration: TimeInterval = 30
    let timeStopPoints = (0 ... totalDuration).linearRandomSplit(jointsCount: 10)
    let delays = [0] + zip(timeStopPoints.dropFirst(), timeStopPoints).map { point, previousPoint in
      point - previousPoint
    }
    let totalDelay = delays.reduce(0, +)
    #expect(totalDelay == 30)
  }

  @Test
  func testDurationIsApproximatelyCorrect() async {
    let stream = AsyncStream.fakeProgress(totalDuration: 1)
    let startTime = Date()
    for await _ in stream { /* Do nothing */ }
    let timeElapsed = Date().timeIntervalSince(startTime)
    #expect(timeElapsed.isApproximatelyEqual(to: 1, absoluteTolerance: 0.1))
  }

  @Test
  func testProgressElementsCount() async {
    let stream = AsyncStream.fakeProgress(totalDuration: 0.1, numberOfDelays: 1000)
    let elementsCount = await stream.reduce(into: 0 as Float) { acc, _ in acc += 1 }
    #expect(elementsCount == 1001)
  }

  @Test
  func testProgressElementsAscending() async {
    let stream = AsyncStream.fakeProgress(totalDuration: 0.1)
    var prevElement: Float?
    for await element in stream {
      #expect(element > prevElement ?? -1)
      prevElement = element
    }
  }

  @Test
  func testProgressElementsBounds() async {
    let stream = AsyncStream.fakeProgress(totalDuration: 0.1)
    var elements: [Float] = []
    for await element in stream {
      elements.append(element)
    }
    #expect(elements.first == 0)
    #expect(elements.last == 1)
  }
}
