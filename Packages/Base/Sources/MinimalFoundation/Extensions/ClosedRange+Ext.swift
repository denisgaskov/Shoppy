//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

#if DEBUG
  extension ClosedRange where
    Bound: BinaryFloatingPoint,
    Bound.RawSignificand: FixedWidthInteger,
    Bound.Stride == Bound
  {
    func linearRandomSplit(jointsCount: Int) -> [Bound] {
      if jointsCount <= 0 {
        assertionFailure("jointsCount should be greater then 0")
        return []
      }
      let length = upperBound - lowerBound
      let strideLength = length / Bound(jointsCount)
      let midElements = stride(from: lowerBound, through: upperBound, by: strideLength).dropFirst().dropLast()
      let randomized = midElements
        .map { element in
          let sign: Bound = Bool.random() ? 1 : -1
          let shift = Bound.random(in: 0 ..< strideLength / 2)
          return element + sign * shift
        }
      return [lowerBound] + randomized + [upperBound]
    }
  }
#endif
