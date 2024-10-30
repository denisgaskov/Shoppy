//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import SwiftUI

extension AppIcon {
  struct View: SwiftUI.View {
    let baseImage: NSImage
    let text: String
    let textColor: Color

    var body: some SwiftUI.View {
      Image(nsImage: baseImage)
        .overlay(alignment: .center) {
          Text(text)
            .lineLimit(1)
            .font(.system(size: fontSize))
            .foregroundStyle(textColor)
            .fontDesign(.rounded)
            .fontWeight(.heavy)
            .padding(.top, centerYOffset)
        }
    }

    private var fontSize: CGFloat {
      baseImage.size.width / 6
    }

    private var centerYOffset: CGFloat {
      baseImage.size.height / 1.5
    }

    var nsImage: NSImage {
      // swiftlint:disable:next force_unwrapping
      ImageRenderer(content: self).nsImage!
    }
  }
}
