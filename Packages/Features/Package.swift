// swift-tools-version: 6.0
// swiftlint:disable:previous file_header

import PackageDescription

// MARK: - Package

let package = Package(
  name: "Features",
  defaultLocalization: "en",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(name: "Root", targets: ["Root"])
  ],
  dependencies: [
    .package(path: "../Base"),
    // .package(path: "../SampleClient"),
    .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0")
  ],
  targets: [
    .target(name: "Auth", dependencies: [.foundation, .ui, .sharedServices]),

    .target(name: "DeveloperTools", dependencies: [.foundation, .ui, .sharedServices]),

    .target(name: "Home", dependencies: [.foundation, .sharedServices, .auth]),

    .target(name: "Launch", dependencies: [
      .foundation, .sharedServices, "DeveloperTools",
      .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
    ]),
    .testTarget(name: "LaunchTests", dependencies: ["Launch"]),

    .target(
      name: "Root",
      dependencies: [.foundation] + ["Launch", .auth, "Home"]
    )
  ]
)

// MARK: - Aliases

extension Target.Dependency {
  static var foundation: Self { .product(name: "MinimalFoundation", package: "Base") }
  static var ui: Self { .product(name: "MinimalUI", package: "Base") }
  static var sharedServices: Self { .product(name: "MinimalSharedServices", package: "Base") }
  static var api: Self { .product(name: "SampleClient", package: "SampleClient") }
  static var auth: Self { "Auth" }
}
