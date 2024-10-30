//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Auth
import MinimalFoundation
import MinimalUI
import SwiftUI

// MARK: - HomeView

public struct HomeView: View {
  @Injected(\.authService)
  private var authService

  let didLogout: Callback

  public var body: some View {
    Button("Log out") {
      Task {
        await authService.logout()
        didLogout()
      }
    }
  }

  public init(didLogout: @escaping Callback) {
    self.didLogout = didLogout
  }
}

// MARK: - Preview

#if DEBUG
  #Preview {
    HomeView {
      print("Did logout")
    }
  }
#endif
