//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import DeveloperTools
import SwiftUI

public struct AppScene: Scene {
  public var body: some Scene {
    WindowGroup {
      RootView()
    }

    #if DEBUG && os(macOS)
      WindowGroup("Debug") {
        DebugMenuScreen()
      }
    #endif
  }

  public init() {}
}
