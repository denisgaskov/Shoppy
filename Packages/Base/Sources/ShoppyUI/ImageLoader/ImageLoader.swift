//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import UIKit
import ShoppyFoundation

extension Container {
  public var imageLoader: Factory<ImageLoader> {
    self { DefaultImageLoader() }
      .cached
  }
}

// MARK: - ImageLoadingError

enum ImageLoadingError: Error {
  case invalidURL
  case downsamplingFailed
}

// MARK: - ImageLoader

public protocol ImageLoader: Sendable {
  func load(from url: URL) async throws -> UIImage
}

// MARK: - DefaultImageLoader

actor DefaultImageLoader: ImageLoader {
  private let session = URLSession.shared

  // In task definition it was said "64x64 **pixels**".
  // I suppose it was meant logical "points" and not raw "pixels" -
  // the image will be either super small, or super blurry.
  // However, I implemented both approaches - just set `screenScale` to `1` below.
  private let targetSize = CGSize(width: 64, height: 64)

  func load(from url: URL) async throws -> UIImage {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions) else {
      throw ImageLoadingError.invalidURL
    }

    // Uncomment line below, if you want to use "pixels"
    // let screenScale: CGFloat = 1
    let screenScale = await UIScreen.main.scale
    let maxDimentionInPixels = max(targetSize.width, targetSize.height) * screenScale

    let downsampledOptions = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels
    ] as CFDictionary

    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) else {
      throw ImageLoadingError.downsamplingFailed
    }

    return UIImage(cgImage: downsampledImage)
  }
}

// MARK: - Preview

import SwiftUI

#Preview {
  @Previewable
  @State
  var uiImage: UIImage?

  @Previewable
  var imageLoader = DefaultImageLoader()

  if let uiImage {
    Image(uiImage: uiImage)
      .resizable()
      .scaledToFit()
      .frame(width: 128)
      .border(.black)
  } else {
    Image(systemName: "circle")
      .task {
        uiImage = try? await imageLoader.load(from: .preview)
      }
  }
}
