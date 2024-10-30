//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalFoundation
import MinimalSharedServices
import MinimalUI
import SwiftUI

// MARK: - SplashView

public struct SplashView: View {
  @Injected(\.logger.bootstrap)
  private var logger

  @Injected(\.executionContext)
  private var executionContext

  @Injected(\.bootstrapInteractor)
  private var bootstrapInteractor

  @State
  private var progress: Float = 0
  private let didFinish: Callback

  public var body: some View {
    launchImage
      .overlay(alignment: .bottom) {
        Group {
          if !progress.isZero {
            ProgressView(value: progress)
              .animation(.default, value: progress)
              .transition(.asymmetric(
                insertion: .opacity.animation(.default.delay(1)),
                removal: .opacity
              ))
          }
        }
        .alignmentGuide(.bottom) { _ in
          -100
        }
      }
      .task {
        for await progress in bootstrapInteractor.bootstrap() {
          self.progress = progress
          logger.debug("Set bootstrap progress \(progress)")
        }
        // Suppress Xcode Preview error, by using string interpolation in Logger.
        // "Compiling failed: argument must be a string interpolation"
        logger.info("Bootstrap finished\("")")
        didFinish()
      }
  }

  @ViewBuilder
  private var launchImage: some View {
    if executionContext.isPreview {
      // SwiftUI Preview can't load asset from main bundle.
      // As a workaround (for Preview only), we're using Rectangle with size of LaunchImage as a template
      Rectangle()
        .fill(.secondary)
        .frame(width: 271, height: 95)
    } else {
      Image("LaunchImage", bundle: .main)
    }
  }

  public init(didFinish: @escaping Callback) {
    self.didFinish = didFinish
  }
}

// MARK: - Preview

#if DEBUG
  #Preview {
    SplashView {
      print("Finished")
    }
  }
#endif
