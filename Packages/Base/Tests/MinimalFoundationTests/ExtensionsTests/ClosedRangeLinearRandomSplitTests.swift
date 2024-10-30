//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import MinimalFoundation

struct ClosedRangeLinearRandomSplitTests {
  @Test
  func testUnitRange10() {
    let range: ClosedRange<Float> = 0 ... 1
    let split = range.linearRandomSplit(jointsCount: 10)

    #expect(split.sorted() == split)
    #expect(split.first == 0)
    #expect(split.last == 1)
    #expect(split.count == 11)
  }

  @Test
  func testUnitRange10000() {
    let range: ClosedRange<Float> = 0 ... 1
    let split = range.linearRandomSplit(jointsCount: 10000)

    #expect(split.sorted() == split)
    #expect(split.first == 0)
    #expect(split.last == 1)
    #expect(split.count == 10001)
  }

  @Test
  func testUnitRange0() throws {
    let range: ClosedRange<Float> = 0 ... 1
    let reporter = AssertionFailureReporterMock()
    Container.shared.assertionFailureReporter.register {
      reporter
    }
    let split = range.linearRandomSplit(jointsCount: 0)

    #expect(split.isEmpty)
    #expect(reporter.invocations == ["jointsCount should be greater then 0"])
  }

  @Test
  func testUnitRange1() {
    let range: ClosedRange<Float> = 0 ... 1
    let split = range.linearRandomSplit(jointsCount: 1)

    #expect(split.first == 0)
    #expect(split.last == 1)
    #expect(split.count == 2)
  }

  @Test
  func testCustomUnitRange100() {
    let range: ClosedRange<Float> = 10 ... 20
    let split = range.linearRandomSplit(jointsCount: 100)

    #expect(split.sorted() == split)
    #expect(split.first == 10)
    #expect(split.last == 20)
    #expect(split.count == 101)
  }
}
