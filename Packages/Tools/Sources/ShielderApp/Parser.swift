//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

// MARK: - File

struct File: Equatable {
  struct Entry: Equatable {
    let key: String
    let value: String
    let type: ValueType
  }

  let path: String
  let rawContent: String
  let content: [Entry]
  let header: String?

  subscript(_ key: String) -> String? {
    content.first { $0.key == key }?.value
  }
}

// MARK: - File.Entry.ValueType

extension File.Entry {
  enum ValueType {
    case url
    case string
  }
}

// MARK: - Parser

struct Parser {
  static let commentToken = "#"

  func getContent(fileContent: String) -> [File.Entry] {
    fileContent
      .split(separator: "\n")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.starts(with: Self.commentToken) } // strip full-line comments
      .compactMap { line in
        var items = line
          .split(separator: "=", maxSplits: 1)
          .map { $0.trimmingCharacters(in: .whitespaces) }

        if items.count != 2 {
          // value is missing, assume it's empty
          items.append("")
        }

        let key = items[0]
        let value = items[1]
        let type = key.split(separator: "_").last.flatMap { File.Entry.ValueType(rawValue: String($0)) }

        return File.Entry(
          key: key,
          value: value,
          type: type ?? .string
        )
      }
  }

  func getHeader(fileContent: String) -> String? {
    let name = fileContent
      .split(separator: "\n")
      .lazy
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .first { $0.starts(with: Self.commentToken) }?
      .dropFirst() // delete comment token
      .trimmingCharacters(in: .whitespaces) // delete remaining whitespaces after comment token

    return name.flatMap { $0.isEmpty ? nil : $0 }
  }
}

// MARK: - File + initFromPath

extension File {
  init(fromPath path: String) throws {
    let parser = Parser()
    self.path = path
    rawContent = try String(contentsOfFile: path)
    content = parser.getContent(fileContent: rawContent)
    header = parser.getHeader(fileContent: rawContent)
  }
}

// MARK: - ValueType + init

extension File.Entry.ValueType {
  fileprivate init?(rawValue: String) {
    switch rawValue.lowercased() {
      case "url": self = .url
      default: return nil
    }
  }
}
