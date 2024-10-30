// swift-tools-version: 6.0
// swiftlint:disable:previous file_header

import PackageDescription

// MARK: - Package

let package = Package(
  name: "Base",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(name: "MinimalFoundation", targets: ["MinimalFoundation"]),
    .library(name: "MinimalUI", targets: ["MinimalUI"]),
    .library(name: "MinimalSharedServices", targets: ["MinimalSharedServices"])
  ],
  dependencies: [
    .package(path: "../Tools"),
    // TODO: [10/20/2024] - check if there's a stable release of Factory after Release of Xcode 16
    .package(url: "https://github.com/hmlongco/Factory", branch: "swift6"),
    .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.2")
  ],
  targets: [
    .target(
      name: "MinimalFoundation",
      dependencies: [.product(name: "Factory", package: "Factory")],
      plugins: [.plugin(name: "Shielder", package: "Tools")]
    ),
    .testTarget(name: "MinimalFoundationTests", dependencies: [
      .foundation,
      .product(name: "Numerics", package: "swift-numerics")
    ]),

    .target(name: "MinimalUI", dependencies: [.foundation]),
    .testTarget(name: "MinimalUITests", dependencies: [.ui]),

    .target(name: "MinimalSharedServices", dependencies: [.foundation, .ui]),
    .testTarget(name: "MinimalSharedServicesTests", dependencies: [.sharedServices])
  ]
)

// MARK: - Aliases

extension Target.Dependency {
  static var foundation: Self { "MinimalFoundation" }
  static var ui: Self { "MinimalUI" }
  static var sharedServices: Self { "MinimalSharedServices" }
  static var macros: Self { .product(name: "Macros", package: "Tools") }
}
