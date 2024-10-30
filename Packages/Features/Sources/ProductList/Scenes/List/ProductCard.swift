//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import ShoppyUI
import ShoppyFoundation
import SwiftUI

/// Product card, which desplays details of `Product` item.
/// Supports light/dark ColorScheme, and responds to SizeCategory changes.
/// Supports image loading interruption (cancellation), when card goes off the screen.
struct ProductCard: View {
  @State
  private var thumbnail: UIImage?

  private let imageLoader = Container.shared.imageLoader()
  private let imageLoaderLogger = Container.shared.logger.imageLoader()

  let product: Product

  var body: some View {
    HStack(alignment: .top) {
      image

      VStack(alignment: .leading) {
        Text(product.name)
          .font(.title2)

        Text(product.price, format: .currency(code: product.currencyCode))
          .font(.subheadline)
          .padding(.bottom, 4)

        HStack {
          Text("Availability: \(product.itemsInStockCount) items")
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding()
    .background {
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.cardBackground)
        .shadow(radius: 2)
    }
  }

  private var image: some View {
    Group {
      if let thumbnail {
        Image(uiImage: thumbnail)
          .resizable()
          .scaledToFit()
      } else {
        Image(systemName: "photo")
          .resizable()
          .scaledToFit()
          .padding()
      }
    }
    .frame(width: 64, height: 64)
    .task {
      if let imageURL = product.image {
        do {
          thumbnail = try await imageLoader.load(from: imageURL)
        } catch {
          let id = imageURL.deletingLastPathComponent().lastPathComponent
          if error is CancellationError {
            imageLoaderLogger.debug("Loading image [\(id)] cancelled.")
          } else {
            imageLoaderLogger.error("Failed to load image [\(id)]: \(error)")
          }
        }
      }
    }
  }
}

#if DEBUG
  #Preview {
    ProductCard(product: .preview)
      .padding()
  }
#endif
