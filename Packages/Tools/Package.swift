// swift-tools-version: 6.0
// swiftlint:disable:previous file_header

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "Tools",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .plugin(name: "Linter", targets: ["Linter"]),
    .plugin(name: "Formatter", targets: ["Formatter"]),
  ],
  targets: [
    .plugin(
      name: "Formatter",
      capability: .command(
        intent: .sourceCodeFormatting(),
        permissions: [.writeToPackageDirectory(reason: "Format source code")]
      ),
      dependencies: ["SwiftLintBinary", "SwiftFormatBinary"]
    ),
    .plugin(
      name: "Linter",
      capability: .buildTool,
      dependencies: ["SwiftLintBinary", "SwiftFormatBinary"]
    ),

    .binaryTarget(
      name: "SwiftLintBinary",
      url: "https://github.com/realm/SwiftLint/releases/download/0.56.2/SwiftLintBinary-macos.artifactbundle.zip",
      checksum: "197df93d7f5041d8cd46d6902a34ad57914efe1b5b50635995f3b9065f2c3ffd"
    ),
    .binaryTarget(
      name: "SwiftFormatBinary",
      url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.54.4/swiftformat.artifactbundle.zip",
      checksum: "24cb612f947e1d59e9007bcf27fb0365194f1b362042a0b7792a89b89b1f5287"
    )
  ]
)