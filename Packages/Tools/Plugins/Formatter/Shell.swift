//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import Foundation

@discardableResult
func safeShell(_ command: String) throws -> String {
  let task = Process()
  let pipe = Pipe()

  task.standardOutput = pipe
  task.standardError = pipe
  task.arguments = ["-c", command]
  task.executableURL = URL(filePath: "/bin/sh")
  task.standardInput = nil

  try task.run()

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  return String(decoding: data, as: UTF8.self)
}

func shell(_ command: String) {
  do {
    try print(safeShell(command))
  } catch {
    print("Error happened: \(error)")
  }
}
