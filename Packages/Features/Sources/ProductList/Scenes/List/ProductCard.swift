//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import MinimalUI
import SwiftUI

struct ProductCard: View {
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
    // Since caching is not required in this task, it's fine just to use AsyncImage.
    // In real scenario, it's adviced to use either modern 3rd party library,
    // or to write custom in-house implementation with caching.
    AsyncImage(url: product.image) { image in
      image
        .resizable()
        .scaledToFit()
    } placeholder: {
      Image(systemName: "photo")
        .resizable()
        .scaledToFit()
        .padding()
        .symbolRenderingMode(.multicolor)
    }
    // In task definition it's said "64x64 pixels".
    // However, I suppose it's meant "points" and not "pixels" - otherwise
    // the image will be either super small, or super blurry.
    .frame(width: 64, height: 64)
  }
}

#if DEBUG
  #Preview {
    ProductCard(product: .preview)
      .padding()
  }
#endif
