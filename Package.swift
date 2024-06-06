// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
  name: "KeyValueCoding",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5)
  ],
  products: [
    .library(
      name: "KeyValueCoding",
      targets: ["KeyValueCoding"]),
  ],
  targets: [
    .target(name: "KeyValueCoding"),
    .testTarget(
      name: "KeyValueCodingTests",
      dependencies: ["KeyValueCoding"]),
  ],
  swiftLanguageVersions: [.v5]
)
