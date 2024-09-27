//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ProductList
import SwiftUI

public struct AppScene: Scene {
  public var body: some Scene {
    WindowGroup {
      NavigationStack {
        ProductListView()
      }
    }
  }

  public init() {}
}
