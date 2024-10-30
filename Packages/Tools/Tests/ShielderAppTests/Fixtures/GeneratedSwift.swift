//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

enum GeneratedSwift {
  static func generatedSwiftCode(cryptoKeyBytes: [UInt8], myServerURLBytes: [UInt8], myAPIKeyBytes: [UInt8]) -> String {
    """
    import Foundation
    import CryptoKit

    private let keyBytes: [UInt8] = \(cryptoKeyBytes)
    private var key: SymmetricKey { SymmetricKey(data: keyBytes) }

    private func decrypt(_ bytes: [UInt8]) -> String {
      if
        let sealedBox = try? ChaChaPoly.SealedBox(combined: bytes),
        let decodedData = try? ChaChaPoly.open(sealedBox, using: key)
      {
        String(decoding: decodedData, as: UTF8.self)
      } else {
        ""
      }
    }

    public protocol Secrets: Sendable {
      var myServerURL: URL { get }

      var myAPIKey: String { get }
    }

    public struct ShielderSecrets: Secrets {
      public var myServerURL: URL { URL(string: decrypt(\(myServerURLBytes)))! }

      public var myAPIKey: String { decrypt(\(myAPIKeyBytes)) }
    }
    """
  }
}
