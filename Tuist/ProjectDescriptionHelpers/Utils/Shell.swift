//
//  Shoppy
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

@discardableResult
func shell(_ command: String) -> String {
  let task = Process()
  let pipe = Pipe()

  task.standardOutput = pipe
  task.standardError = pipe
  task.arguments = ["-c", command]
  task.executableURL = URL(filePath: "/bin/sh")
  task.standardInput = nil

  // swiftlint:disable:next force_try
  try! task.run()

  let data = pipe.fileHandleForReading.readDataToEndOfFile().dropLast()
  return String(decoding: data, as: UTF8.self)
}
