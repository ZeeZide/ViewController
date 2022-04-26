// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "ViewController",
  platforms: [ .macOS(.v11), .iOS(.v15) ],
  products: [ .library(name: "ViewController", targets: [ "ViewController" ]) ],
  targets: [
    .target(name: "ViewController")
  ]
)
