//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Testing
@testable import ShielderApp

enum ValidatorTests {
  // MARK: - EnvLock

  struct EnvLock {
    let validator = Validator()

    @Test
    func noDuplicatedKeys() throws {
      let envLock = File(
        path: "",
        rawContent: "",
        content: [
          .init(key: "staging", value: "hash", type: .string),
          .init(key: "production", value: "hash", type: .string)
        ],
        header: nil
      )
      try validator.validateEnvLock(file: envLock)
    }

    @Test
    func duplicatedKeys() throws {
      let envLock = File(
        path: "envLockPath",
        rawContent: "",
        content: [
          .init(key: "staging", value: "hash", type: .string),
          .init(key: "staging", value: "hash", type: .string)
        ],
        header: nil
      )

      #expect(throws: TextError(rawMessage: "envLockPath: error: .env.lock contains duplicated keys.")) {
        try validator.validateEnvLock(file: envLock)
      }
    }
  }

  // MARK: - EnvIntegrity

  struct EnvIntegrity {
    let validator = Validator()

    @Test
    func correctSHA() throws {
      let env = File(
        path: "",
        rawContent: "fake content",
        content: [],
        header: "staging"
      )

      let envLock = File(
        path: "envLockPath",
        rawContent: "",
        content: [
          // swiftlint:disable:next line_length
          .init(key: "staging", value: "98b1ae45059b004178a8eee0c1f6179dcea139c0fd8a69ee47a6f02d97af1f17", type: .string)
        ],
        header: nil
      )

      try validator.validateEnvIntegrity(env: env, envLock: envLock)
    }

    @Test
    func incorrectSHA() throws {
      let env = File(
        path: "",
        rawContent: "fake content",
        content: [],
        header: "staging"
      )

      let envLock = File(
        path: "envLockPath",
        rawContent: "",
        content: [
          .init(key: "staging", value: "hash", type: .string)
        ],
        header: nil
      )

      // swiftlint:disable:next line_length
      #expect(throws: TextError(rawMessage: "envLockPath: error: SHA of 'staging' does not match. Actual: 98b1ae45059b004178a8eee0c1f6179dcea139c0fd8a69ee47a6f02d97af1f17.")) {
        try validator.validateEnvIntegrity(env: env, envLock: envLock)
      }
    }

    @Test
    func missingEnvName() throws {
      let env = File(
        path: "envPath",
        rawContent: "fake content",
        content: [],
        header: nil
      )

      let envLock = File(
        path: "",
        rawContent: "",
        content: [],
        header: nil
      )

      #expect(throws: TextError(rawMessage: "envPath: error: .env has no name configured.")) {
        try validator.validateEnvIntegrity(env: env, envLock: envLock)
      }
    }
  }

  // MARK: - EnvTypes

  struct EnvTypes {
    let validator = Validator()

    @Test
    func validURL() throws {
      let env = file(withSingleEntry: .init(key: "my_server_url", value: "https://example.com", type: .url))
      try validator.validateEnvTypes(env: env)
    }

    @Test
    func invalidURL() throws {
      let env = file(withSingleEntry: .init(key: "my_server_url", value: "", type: .url))
      // swiftlint:disable:next line_length
      #expect(throws: TextError(rawMessage: "envPath: error: Value at key my_server_url is declared to be URL, but it's not URL-compatible.")) {
        try validator.validateEnvTypes(env: env)
      }
    }

    func file(withSingleEntry entry: File.Entry) -> File {
      File(
        path: "envPath",
        rawContent: "",
        content: [entry],
        header: ""
      )
    }
  }
}
