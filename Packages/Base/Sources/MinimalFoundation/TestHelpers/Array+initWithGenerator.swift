//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

#if DEBUG
  extension Array {
    public init(count: Int, generator: @autoclosure () -> Element) {
      var array: [Element] = []
      array.reserveCapacity(count)
      for _ in 0 ..< count {
        array.append(generator())
      }
      self = array
    }
  }
#endif
