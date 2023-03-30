// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Networking",
            targets: [
                "Networking",
                "AuthenticationNetworking",
                "VehiclesDataNetworking",
                "VehicleCommandsNetworking",
                "VehicleCommandsChargingNetworking"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", exact: "0.2.0"),
        .package(url: "https://github.com/igashev/NetworkRequester.git", exact: "1.4.0"),
        .package(name: "Models", path: "../Models"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Networking",
            dependencies: [
                "NetworkRequester",
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"]),
        .target(name: "AuthenticationNetworking", dependencies: ["Networking", "Models"], path: "Sources/Authentication"),
        .testTarget(name: "AuthenticationNetworkingTests", dependencies: ["AuthenticationNetworking"], path: "Tests/Authentication"),
        .target(name: "VehiclesDataNetworking", dependencies: ["Networking", "Models"], path: "Sources/VehiclesData"),
        .target(name: "VehicleCommandsNetworking", dependencies: ["Networking", "Models"], path: "Sources/VehicleCommands"),
        .target(name: "VehicleCommandsChargingNetworking", dependencies: ["Networking", "Models"], path: "Sources/VehicleCommandsCharging")
    ]
)
