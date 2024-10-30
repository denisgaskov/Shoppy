//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import MinimalSharedServices
import MinimalUI
import SwiftUI

#if DEBUG
  enum DebugMenuRoute {
    case openLogs
  }

  struct DebugMenuContentView: View {
    @AppStorage(StoreKey.shouldResetAndDelayLaunchScreen.name)
    private var shouldResetAndDelayLaunchScreen = false

    @Binding
    var selection: DebugMenuRoute?

    var body: some View {
      List(selection: $selection) {
        Section {
          Toggle("Reset and delay Launch Screen", systemImage: "iphone", isOn: $shouldResetAndDelayLaunchScreen)
        } footer: {
          if shouldResetAndDelayLaunchScreen {
            Text("Relaunch app to see changes")
              .animation(.default, value: shouldResetAndDelayLaunchScreen)
          }
        }

        Section("Logging") {
          NavigationLink(value: DebugMenuRoute.openLogs) {
            Label("Logs", systemImage: "text.document")
          }

          Button("Crash app", systemImage: "ladybug") {
            let array: [Int] = []
            _ = array[100]
          }
        }
      }
    }
  }

  #Preview {
    DebugMenuContentView(selection: .constant(nil))
  }
#endif
