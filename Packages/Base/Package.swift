// swift-tools-version: 6.0
// swiftlint:disable:previous file_header

import PackageDescription

// MARK: - Package

let package = Package(
  name: "Base",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(name: "MinimalFoundation", targets: ["MinimalFoundation"]),
    .library(name: "MinimalUI", targets: ["MinimalUI"])
  ],
  dependencies: [
    // The only one external dependency used.
    // Alternatives (including in-house variants) are listed in README.md.
    .package(url: "https://github.com/hmlongco/Factory", from: "2.4.1")
  ],
  targets: [
    .target(
      name: "MinimalFoundation",
      dependencies: [.product(name: "Factory", package: "Factory")]
    ),

    .target(name: "MinimalUI", dependencies: [.foundation]),
    .testTarget(name: "MinimalUITests", dependencies: [.ui])
  ]
)

// MARK: - Aliases

extension Target.Dependency {
  static var foundation: Self { "MinimalFoundation" }
  static var ui: Self { "MinimalUI" }
}
