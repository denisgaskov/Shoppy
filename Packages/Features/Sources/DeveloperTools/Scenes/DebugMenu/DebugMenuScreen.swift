//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import MinimalSharedServices
import SwiftUI

#if DEBUG
  public struct DebugMenuScreen: View {
    @State
    private var selection: DebugMenuRoute?

    public var body: some View {
      NavigationSplitView {
        DebugMenuContentView(selection: $selection)
          .navigationTitle("Debug Menu")
      } detail: {
        switch selection {
          case .openLogs:
            LogsView()
          case nil:
            Text("Select section")
        }
      }
      .defaultAppStorage(.developerTools ?? .standard)
    }

    public init() {}
  }

  #Preview {
    DebugMenuScreen()
  }
#endif
