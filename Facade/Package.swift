// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Facade",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Facade", targets: ["AuthenticationFacade", "VehiclesDataFacade"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", exact: "0.2.0"),
        .package(name: "Networking", path: "../Networking"),
        .package(name: "Caching", path: "../Caching"),
        .package(name: "Models", path: "../Models"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AuthenticationFacade",
            dependencies: [
                "Networking",
                "Caching",
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            path: "Sources/Authentication"
        ),
        .target(name: "VehiclesDataFacade", path: "Sources/VehiclesData"),
        .testTarget(
            name: "AuthenticationFacadeTests",
            dependencies: ["AuthenticationFacade"],
            path: "Tests/AuthenticationTests"
        )
    ]
)
