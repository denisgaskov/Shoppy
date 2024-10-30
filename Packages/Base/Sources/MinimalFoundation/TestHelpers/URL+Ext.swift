//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

#if DEBUG
  extension URL {
    // swiftlint:disable:next force_unwrapping
    public static let example = URL(string: "https://example.com")!
  }
#endif
