// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RevenexxSample",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/revenexx-sdks/swift", from: "0.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "RevenexxSample",
            dependencies: [
                .product(name: "Revenexx", package: "swift")
            ]
        ),
    ]
)
