//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

#if DEBUG
  extension AsyncStream where Element == Float {
    public static func fakeProgress(
      totalDuration: TimeInterval,
      range: ClosedRange<Element> = 0 ... 1,
      numberOfDelays: Int = 10
    ) -> Self {
      AsyncStream { continuation in
        let progress = range.linearRandomSplit(jointsCount: numberOfDelays)
        let timeStopPoints = (0 ... totalDuration).linearRandomSplit(jointsCount: numberOfDelays)
        let delays = [0] + zip(timeStopPoints.dropFirst(), timeStopPoints).map { point, previousPoint in
          point - previousPoint
        }
        let task = Task {
          for (progress, delay) in zip(progress, delays) {
            try? await Task.sleep(for: .seconds(delay))
            continuation.yield(progress)
            if Task.isCancelled {
              break
            }
          }
          continuation.finish()
        }
        continuation.onTermination = { _ in
          task.cancel()
        }
      }
    }
  }
#endif
