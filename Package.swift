// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppleTVBlur",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "AppleTVBlur", targets: ["AppleTVBlur"])
    ],
    targets: [
        .target(name: "AppleTVBlur")
    ]
)
