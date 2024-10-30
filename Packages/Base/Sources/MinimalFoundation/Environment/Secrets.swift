// swiftlint:disable:this file_name
//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Factory
import Foundation

extension Container {
  public var secrets: Factory<Secrets> {
    self { ShielderSecrets() }
  }
}
