//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Auth
import Home
import Launch
import MinimalFoundation
import MinimalSharedServices
import SwiftUI

// MARK: - RootViewState

enum RootViewState {
  case splash
  case auth
  case home
}

// MARK: - RootView

public struct RootView: View {
  @Injected(\.developerTools)
  private var developerTools

  @Injected(\.authService)
  private var authService

  @State
  private var state: RootViewState = .splash

  public var body: some View {
    Group {
      switch state {
        case .splash:
          SplashView {
            Task {
              state = await authService.isAuthorized ? .home : .auth
            }
          }

        case .auth:
          AuthView {
            state = .home
          }

        case .home:
          HomeView {
            state = .auth
          }
      }
    }
    .animation(.default, value: state)
  }

  public init() {
    developerTools?.resetAndDelayLaunchScreenIfNeeded()
  }
}

// MARK: - Preview

#if DEBUG
  #Preview {
    RootView()
  }
#endif
