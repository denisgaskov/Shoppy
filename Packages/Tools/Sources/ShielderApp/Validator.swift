//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

struct Validator {
  func validateEnvLock(file: File) throws {
    if Set(file.content.map(\.key)).count != file.content.count {
      throw TextError(at: file.path, ".env.lock contains duplicated keys.")
    }
  }

  func validateEnvIntegrity(env: File, envLock: File) throws {
    guard let envName = env.header else {
      throw TextError(at: env.path, ".env has no name configured.")
    }

    let actualSHA = try Crypto.SHA(content: env.rawContent)
    if actualSHA != envLock[envName] {
      throw TextError(at: envLock.path, "SHA of '\(envName)' does not match. Actual: \(actualSHA).")
    }
  }

  func validateEnvTypes(env: File) throws {
    for entry in env.content {
      switch entry.type {
        case .url: try validateURL(string: entry.value, key: entry.key, envPath: env.path)
        case .string: continue
      }
    }
  }

  private func validateURL(string: String, key: String, envPath: String) throws {
    if URL(string: string) == nil {
      throw TextError(at: envPath, "Value at key \(key) is declared to be URL, but it's not URL-compatible.")
    }
  }
}
