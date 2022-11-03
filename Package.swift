// swift-tools-version:5.6
import PackageDescription

let name = "HideDockAndStageManager"
let package = Package(
  name: name,
  platforms: [.macOS(.v12)],
  products: [],
  targets: [
    .executableTarget(name: name)
  ]
)

