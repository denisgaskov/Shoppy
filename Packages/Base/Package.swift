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
    .package(url: "https://github.com/hmlongco/Factory", from: "2.4.1")
  ],
  targets: [
    .target(
      name: "MinimalFoundation",
      dependencies: [.product(name: "Factory", package: "Factory")]
    ),
    .testTarget(
      name: "MinimalFoundationTests",
      dependencies: [.foundation]
    ),

    .target(name: "MinimalUI", dependencies: [.foundation])
  ]
)

// MARK: - Aliases

extension Target.Dependency {
  static var foundation: Self { "MinimalFoundation" }
  static var ui: Self { "MinimalUI" }
}
