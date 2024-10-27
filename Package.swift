// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "google-cloud-logging",
    platforms: [
       .macOS(.v15),
    ],
    products: [
        .library(name: "GoogleCloudLogging", targets: ["GoogleCloudLogging"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
        .package(url: "https://github.com/rosecoder/google-cloud-service-context.git", revision: "5464a8beb9b4d4d93cc219313b207bd82cc128bb"),
    ],
    targets: [
        .target(
            name: "GoogleCloudLogging",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "GoogleCloudServiceContext", package: "google-cloud-service-context"),
            ]
        ),
        .testTarget(
            name: "GoogleCloudLoggingTests",
            dependencies: ["GoogleCloudLogging"]
        ),
    ]
)
