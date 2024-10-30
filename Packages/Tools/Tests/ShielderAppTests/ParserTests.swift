//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation
import Testing
@testable import ShielderApp

// MARK: - ParserTests

enum ParserTests {
  // MARK: Header

  struct Header {
    let parser = Parser()

    @Test(arguments: [DotEnvFile.basic, DotEnvFile.firstEmptyLine])
    func extractPresentHeader(fileContent: String) {
      let header = parser.getHeader(fileContent: fileContent)
      #expect(header == "staging")
    }

    @Test
    func extractEmptyHeader() {
      let none = parser.getHeader(fileContent: DotEnvFile.noHeader)
      #expect(none == nil)
    }
  }

  // MARK: Content

  struct Content {
    let parser = Parser()

    @Test
    func basic() {
      let content = parser.getContent(fileContent: DotEnvFile.basic)
      #expect(content == [
        .init(key: "my_serverurl", value: "https://example.com", type: .string),
        .init(key: "my_api_key", value: "Alzafoobar", type: .string)
      ])
    }

    @Test
    func typed() {
      let content = parser.getContent(fileContent: DotEnvFile.basicTyped)
      #expect(content == [
        .init(key: "my_server_url", value: "https://example.com", type: .url),
        .init(key: "my_api_key", value: "Alzafoobar", type: .string)
      ])
    }

    @Test
    func emptyValue() {
      let content = parser.getContent(fileContent: DotEnvFile.noValueForKeys)
      #expect(content == [
        .init(key: "my_server_url", value: "", type: .url),
        .init(key: "my_api_key", value: "", type: .string)
      ])
    }
  }

  // MARK: Formatting

  struct Formatting {
    let parser = Parser()

    @Test
    func worstCase() {
      let header = parser.getHeader(fileContent: DotEnvFile.worstCaseFormatting)
      #expect(header == "staging#bad=name")

      let content = parser.getContent(fileContent: DotEnvFile.worstCaseFormatting)
      #expect(content == [
        .init(key: "my_server#hash", value: "https://example.com/a=b#123", type: .string)
      ])
    }
  }
}

// MARK: - FileTests

struct FileTests {
  @Test
  func basicTyped() throws {
    let path = DotEnvFile.basicTyped.writeToTemporaryPath()
    let file = try File(fromPath: path)
    #expect(file == File(
      path: path,
      rawContent: DotEnvFile.basicTyped,
      content: [
        .init(key: "my_server_url", value: "https://example.com", type: .url),
        .init(key: "my_api_key", value: "Alzafoobar", type: .string)
      ],
      header: "staging"
    ))
  }

  @Test
  func noHeader() throws {
    let path = DotEnvFile.noHeader.writeToTemporaryPath()
    let file = try File(fromPath: path)
    #expect(file == File(
      path: path,
      rawContent: DotEnvFile.noHeader,
      content: [],
      header: nil
    ))
  }
}

// MARK: - String + writeToTemporaryPath

extension String {
  /// Writes file to temporary path, suitable for unit testing
  /// - Returns: Temporary path where content was written to
  fileprivate func writeToTemporaryPath() -> String {
    let tempDirectoryURL = FileManager.default.temporaryDirectory
    let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString)
    FileManager.default.createFile(atPath: fileURL.path(), contents: Data(utf8))
    return fileURL.path()
  }
}
