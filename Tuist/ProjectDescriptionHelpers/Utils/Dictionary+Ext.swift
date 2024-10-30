//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

extension Dictionary {
  static func + (lhs: Self, rhs: Self) -> Self {
    lhs.merging(rhs) { $1 }
  }
}
