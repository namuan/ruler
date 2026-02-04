// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Ruler",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .executable(name: "Ruler", targets: ["Ruler"])
  ],
  targets: [
    .executableTarget(
      name: "Ruler",
      path: "Sources/Ruler"
    )
  ]
)
