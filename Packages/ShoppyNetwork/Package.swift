// swift-tools-version: 6.0
// swiftlint:disable:previous file_header

import PackageDescription

let package = Package(
  name: "ShoppyNetwork",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(
      name: "ProductsAPI",
      targets: ["ProductsAPI"]
    )
  ],
  dependencies: [
    .package(path: "../Base")
  ],
  targets: [
    .target(name: "ProductsAPI", dependencies: ["ShoppyNetwork"]),

    .target(
      name: "ShoppyNetwork",
      dependencies: [
        .product(name: "ShoppyFoundation", package: "Base")
      ]
    ),
    .testTarget(
      name: "ShoppyNetworkTests",
      dependencies: ["ShoppyNetwork"]
    )
  ]
)
