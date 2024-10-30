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
  case invalidDataFormat
}

// MARK: - ImageLoader

public protocol ImageLoader: Sendable {
  func load(from url: URL) async throws -> UIImage
}

// MARK: - DefaultImageLoader

/// # Description
/// Loads and downsamples given image
///
/// ## Details
/// In that particular case I suppose it's better to use `URLSession` + `UIGraphicsImageRenderer`,
/// instead of `CGImageSourceCreateThumbnailAtIndex`, because it's non-interrupatble (which is quite important).
/// Also, performance of `CGImageSourceCreateThumbnailAtIndex` is not always better then `UIGraphicsImageRenderer`
/// as per https://nshipster.com/image-resizing
///
/// ## Disclaimer
/// It's still not the best solution in my opinion. We have to load full image from the server,
/// so it's adviced to use server-side image scaling / downsampling instead.
///
/// ## Points or Pixels
/// In task definition it was said "64x64 **pixels**".
/// I assume it was meant logical "points" and not raw "pixels" - othwerwise the image
/// will be either super small, or super blurry on hi-DPI devices.
actor DefaultImageLoader: ImageLoader {
  private let session = URLSession.shared
  private let logger = Container.shared.logger.imageLoader()
  private let targetSize = CGSize(width: 64, height: 64)

  func load(from url: URL) async throws -> UIImage {
    let imageID = "\"\(url.deletingLastPathComponent().lastPathComponent)\""
    logger.debug("Loading \(imageID) on \(Thread.current)")

    let (data, _) = try await session.data(from: url)
    guard let image = UIImage(data: data) else {
      throw ImageLoadingError.invalidDataFormat
    }

    try Task.checkCancellation()

    let rect = CGRect(origin: .zero, size: aspectFitSize(forImageSize: image.size, inBoxSize: targetSize))
    let result = UIGraphicsImageRenderer(size: rect.size).image { _ in
      image.draw(in: rect)
    }

    logger.debug("Downsampled \(imageID)")
    return result
  }

  private func aspectFitSize(forImageSize imageSize: CGSize, inBoxSize boxSize: CGSize) -> CGSize {
    let widthRatio = boxSize.width / imageSize.width
    let heightRatio = boxSize.height / imageSize.height
    let scale = min(widthRatio, heightRatio) // Choose the smaller ratio to fit within the box
    let targetWidth = imageSize.width * scale
    let targetHeight = imageSize.height * scale
    return CGSize(width: targetWidth, height: targetHeight)
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
