//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import MinimalSharedServices
import MinimalUI
import SwiftUI

extension Container {
  public var developerTools: Factory<DeveloperToolsService?> {
    promised()
    #if DEBUG
      .onDebug { DefaultDeveloperToolsService() }
      .cached
    #endif
  }
}

// MARK: - DeveloperToolsService

public protocol DeveloperToolsService {
  @MainActor
  func setupDebugMenu()
  func resetAndDelayLaunchScreenIfNeeded()
}

// MARK: - DefaultDeveloperToolsService

#if DEBUG
  final class DefaultDeveloperToolsService: DeveloperToolsService {
    @Injected(\.developerToolsStore)
    private var store

    @Injected(\.logger.bootstrap)
    private var logger

    private var observationTask: Task<Void, Never>?

    #if canImport(UIKit)
      @MainActor
      private var window: UIWindow?
    #endif

    func setupDebugMenu() {
      // In MacOS, DebugMenuScreen is shown in new Window, by using "File -> New Window" menu. See "AppScene.swift".
      #if canImport(UIKit)
        @MainActor
        func showDebugMenuInNewWindow() -> UIWindow? {
          guard let scene = UIApplication.shared.connectedScenes.lazy.compactMap({ $0 as? UIWindowScene }).first else {
            assertionFailure("No UIWindowScene.")
            return nil
          }

          let window = UIWindow(windowScene: scene)
          class ExtendedHostingController<T: View>: UIHostingController<T> {
            var didDeinit: Callback?

            deinit {
              MainActor.assumeIsolated {
                didDeinit?()
              }
            }
          }
          let viewController = ExtendedHostingController(rootView: DebugMenuScreen())
          viewController.didDeinit = {
            self.window = nil
          }
          window.makeKeyAndVisible()
          window.rootViewController = UIViewController()
          window.rootViewController?.present(viewController, animated: true)
          return window
        }

        observationTask = Task {
          let sequence = NotificationCenter.deviceEvents.notifications(named: UIDevice.deviceDidShakeNotification)
          for await _ in sequence.map({ _ in () }) {
            guard window == nil else {
              logger.info("DebugMenu is already shown.")
              continue
            }
            window = showDebugMenuInNewWindow()
          }
        }
      #endif
    }

    func resetAndDelayLaunchScreenIfNeeded() {
      // LaunchScreen exists in UIKit-based apps only (iOS).
      #if canImport(UIKit)
        guard store.read(forKey: .shouldResetAndDelayLaunchScreen) ?? false else {
          return
        }

        try? FileManager.default.removeItem(atPath: NSHomeDirectory() + "/Library/SplashBoard")
        sleep(5)

        store.write(false, forKey: .shouldResetAndDelayLaunchScreen)
      #endif
    }
  }
#endif
