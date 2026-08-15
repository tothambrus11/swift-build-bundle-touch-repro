// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "Repro",
  targets: [
    .target(
      name: "Foo",
      resources: [.copy("Resources/hello.txt")])
  ])
