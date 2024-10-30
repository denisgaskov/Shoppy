//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import CryptoKit
import Testing
@testable import ShielderApp

// MARK: - AccessModifierTests

struct AccessModifierTests {
  let key = "shielder_access_modifier"

  @Test(arguments: [
    ("public", AccessModifier.public),
    ("internal", AccessModifier.internal)
  ])
  func valid(name: String, expected: AccessModifier) throws {
    let actual = try AccessModifier(envLock: file(modifier: name))
    #expect(actual == expected)
  }

  @Test
  func invalid() {
    #expect(throws: TextError(rawMessage: "envLockPath: error: AccessModifier private is not valid.")) {
      try AccessModifier(envLock: file(modifier: "private"))
    }
  }

  func file(modifier: String) -> File {
    File(path: "envLockPath", rawContent: "", content: [.init(key: key, value: modifier, type: .string)], header: nil)
  }
}

// MARK: - GeneratorTests

struct GeneratorTests {
  // swiftlint:disable:next line_length
  let cryptoKeyBytes: [UInt8] = [108, 207, 131, 141, 147, 135, 162, 219, 210, 215, 134, 13, 194, 58, 132, 245, 75, 69, 27, 255, 31, 239, 133, 204, 72, 152, 108, 94, 120, 164, 247, 50]

  let cryptoKey: Crypto.Key
  let generated: String
  let myServerURLBytes: [UInt8]
  let myAPIKeyBytes: [UInt8]

  init() throws {
    cryptoKey = Crypto.Key(data: cryptoKeyBytes)
    let generator = Generator(
      envContent: [
        .init(key: "my_server_url", value: "https://example.com", type: .url),
        .init(key: "my_api_key", value: "Alzafoobar", type: .string)
      ],
      access: .public,
      cryptoKey: cryptoKey
    )

    generated = try generator.generateSwift()
    let generatedLines = generated.components(separatedBy: "\n")

    myServerURLBytes = getBytes(from: generatedLines[24], startIndex: 53)
    myAPIKeyBytes = getBytes(from: generatedLines[26], startIndex: 41)
  }

  @Test
  func generatedFileContent() {
    let expected = GeneratedSwift.generatedSwiftCode(
      cryptoKeyBytes: cryptoKeyBytes,
      myServerURLBytes: myServerURLBytes,
      myAPIKeyBytes: myAPIKeyBytes
    )
    #expect(expected == generated)
  }

  @Test
  func decryptGeneratedBytes() {
    #expect(decrypt(bytes: myServerURLBytes) == "https://example.com")
    #expect(decrypt(bytes: myAPIKeyBytes) == "Alzafoobar")
  }
}

// MARK: - Support

extension GeneratorTests {
  func decrypt(bytes: [UInt8]) -> String {
    // swiftlint:disable force_try
    let sealedBox = try! ChaChaPoly.SealedBox(combined: bytes)
    let decodedData = try! ChaChaPoly.open(sealedBox, using: cryptoKey)
    // swiftlint:enable force_try
    return String(decoding: decodedData, as: UTF8.self)
  }
}

private func getBytes(from string: String, startIndex: Int) -> [UInt8] {
  let substring = string[String.Index(utf16Offset: startIndex, in: string)...]
  let bytesOnly = substring.prefix { $0.isNumber || $0.isWhitespace || $0 == "," }

  return bytesOnly
    .split(separator: ", ")
    .map { UInt8($0)! }
  // swiftlint:disable:previous force_unwrapping
}
