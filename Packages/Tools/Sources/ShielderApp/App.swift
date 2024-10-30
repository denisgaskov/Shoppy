//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

// MARK: - App

@main
enum App {
  static func mainThrows() throws {
    let env = try File(fromPath: CommandLine.arguments[1])
    let envLock = try File(fromPath: CommandLine.arguments[2])
    let outputPath = CommandLine.arguments[3]

    let validator = Validator()
    try validator.validateEnvLock(file: envLock)
    try validator.validateEnvIntegrity(env: env, envLock: envLock)
    try validator.validateEnvTypes(env: env)

    let accessModifier = try AccessModifier(envLock: envLock)
    let generator = Generator(envContent: env.content, access: accessModifier)
    let outputContent = try generator.generateSwift()
    try outputContent.write(toFile: outputPath, atomically: false, encoding: .utf8)
  }

  static func main() {
    do {
      try mainThrows()
    } catch {
      print(error.localizedDescription)
      exit(-1)
    }
  }
}

// MARK: - TextError

struct TextError: Error, LocalizedError, Equatable {
  let message: String
  var errorDescription: String? { message }

  init(rawMessage: String) {
    message = rawMessage
  }

  init(at path: String, _ message: String) {
    self.message = "\(path): error: \(message)"
  }
}
