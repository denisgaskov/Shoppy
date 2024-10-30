// swift-tools-version: 6.0
// swiftlint:disable:previous file_header

import PackageDescription

let package = Package(
  name: "SampleClient",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(
      name: "SampleClient",
      targets: ["SampleClient"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.3.0"),
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.5.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.2"),
    .package(path: "../Base")
  ],
  targets: [
    .target(
      name: "SampleClient",
      dependencies: [
        .product(name: "MinimalFoundation", package: "Base"),
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
      ],
      plugins: [
        .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
      ]
    )
  ]
)
