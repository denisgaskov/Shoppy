//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

enum KeychainQuery {
  protocol Add: Sendable {
    var query: CFDictionary { get }
  }

  protocol Read: Sendable {
    var query: CFDictionary { get }
  }

  protocol Update: Sendable {
    var query: CFDictionary { get }
    var updateQuery: CFDictionary { get }
  }

  protocol Delete: Sendable {
    var query: CFDictionary { get }
  }
}
