// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ConvertoKit",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "ConvertoKit",
            targets: ["ConvertoKit"]),
    ],
    dependencies: [
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.8.2"))
    ],
    targets: [
        .target(
            name: "ConvertoKit",
            dependencies: []),
        .testTarget(
            name: "ConvertoKitTests",
            dependencies: [
                "ConvertoKit",
                "SnapshotTesting"
            ],
            exclude: [
                "ViewTests/__Snapshots__/"
            ])
    ]
)
