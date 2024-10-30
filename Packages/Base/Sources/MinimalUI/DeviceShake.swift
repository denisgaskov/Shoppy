// swiftlint:disable:this file_name
//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import SwiftUI

#if DEBUG && canImport(UIKit)
  import UIKit

  /// The notification we'll send when a shake gesture happens.
  extension UIDevice {
    public static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
  }

  ///  Override the default behavior of shake gestures to send our notification instead.
  extension UIWindow {
    // swiftlint:disable:next override_in_extension
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with _: UIEvent?) {
      if motion == .motionShake {
        NotificationCenter.deviceEvents.post(name: UIDevice.deviceDidShakeNotification, object: nil)
      }
    }
  }

  /// A view modifier that detects shaking and calls a function of our choosing.
  /// - Warning: At the time of writing view modifiers do not work with onReceive() unless you first add onAppear(), which is why it appears above.
  /// Yes, it’s empty, but it acts as a workaround for the problem.
  struct DeviceShakeViewModifier: ViewModifier {
    let action: Callback

    func body(content: Content) -> some View {
      content
        .onAppear()
        .onReceive(NotificationCenter.deviceEvents.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
          action()
        }
    }
  }

  /// A View extension to make the modifier easier to use.
  extension View {
    public func onShake(perform action: @escaping Callback) -> some View {
      modifier(DeviceShakeViewModifier(action: action))
    }
  }
#endif
