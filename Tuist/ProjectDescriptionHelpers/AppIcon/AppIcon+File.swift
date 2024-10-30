//
//  Minimal
//  Created by Denis Gaskov
//  Copyright © 2024 Denis Gaskov. All rights reserved.
//

import AppKit

// MARK: - AppIcon + files

extension AppIcon {
  static let commonPath = "App/Resources/Assets.xcassets"

  static func prodFiles() throws -> (png: [URL], contentsJSON: URL) {
    let fileManager = FileManager.default
    let relativePath = commonPath + "/AppIcon.appiconset"
    let absolutePath = [fileManager.currentDirectoryPath, relativePath].joined(separator: "/")
    let folderURL = URL(filePath: absolutePath)

    var png: [URL] = []
    var contentsJSON: URL?
    for file in try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil) {
      if file.pathExtension == "png" {
        png.append(file)
      } else if file.lastPathComponent == "Contents.json" {
        contentsJSON = file
      }
    }

    guard let contentsJSON else {
      fatalError("Contents.json not found at \(folderURL)")
    }

    return (png, contentsJSON)
  }

  static func targetDirectory(env: AppEnvironment) -> URL {
    let fileManager = FileManager.default
    let relativePath = commonPath + "/AppIcon\(env.postfix).appiconset"
    let absolutePath = [fileManager.currentDirectoryPath, relativePath].joined(separator: "/")
    return URL(filePath: absolutePath)
  }

  static func loadImageIgnoringDPI(from url: URL) -> NSImage {
    guard
      let image = NSImage(contentsOf: url),
      let rep = image.representations.first
    else {
      fatalError("Image or representation not found at \(url)")
    }

    image.size = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
    return image
  }
}

// MARK: - FileManager + Ext

extension FileManager {
  func copyItemWithFolders(fromURL from: URL, to url: URL) throws {
    let directory = url.deletingLastPathComponent()
    if !fileExists(atPath: directory.path()) {
      try createDirectory(at: directory, withIntermediateDirectories: true)
    }

    if fileExists(atPath: url.path()) {
      try removeItem(at: url)
    }

    try copyItem(at: from, to: url)
  }

  func writeWithFolders(data: Data, to url: URL) throws {
    let directory = url.deletingLastPathComponent()
    if !fileExists(atPath: directory.path()) {
      try createDirectory(at: directory, withIntermediateDirectories: true)
    }

    try data.write(to: url)
  }
}

// MARK: - NSImage + asPNGData

extension NSImage {
  var asPNGData: Data {
    guard
      let imageData = tiffRepresentation,
      let newRep = NSBitmapImageRep(data: imageData),
      let png = newRep.representation(using: .png, properties: [:])
    else {
      fatalError("NSImage to Data returned nil")
    }

    return png
  }
}
