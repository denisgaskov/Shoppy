//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import MinimalUI
import SwiftUI

public struct AuthView: View {
  private let didFinish: Callback

  @Injected(\.authService)
  private var authService

  public var body: some View {
    Button("Sign in") {
      Task {
        do {
          try await authService.signIn(login: "foo", password: "pass")
          didFinish()
        } catch {
          print("error")
        }
      }
    }
  }

  public init(didFinish: @escaping Callback) {
    self.didFinish = didFinish
  }
}
