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
    .package(path: "../ShoppyNetwork")
  ],
  targets: [
    .target(name: "ProductList", dependencies: [.foundation, .ui, .productsAPI]),

    .target(
      name: "Root",
      dependencies: [.foundation] + ["ProductList"]
    )
  ]
)

// MARK: - Aliases

extension Target.Dependency {
  static var foundation: Self { .product(name: "ShoppyFoundation", package: "Base") }
  static var ui: Self { .product(name: "ShoppyUI", package: "Base") }
  static var productsAPI: Self { .product(name: "ProductsAPI", package: "ShoppyNetwork") }
}
