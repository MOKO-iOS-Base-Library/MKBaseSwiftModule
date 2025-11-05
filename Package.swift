// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MKBaseSwiftModule",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "MKBaseSwiftModule",
            targets: ["MKBaseSwiftModule"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "MKBaseSwiftModule",
            dependencies: [
                
            ],
            path: "Sources",
            resources: [
                .process("Assets")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("IOS15_OR_LATER")
            ],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("iconv")
            ]
        ),
        .testTarget(
            name: "MKBaseSwiftModuleTests",
            dependencies: ["MKBaseSwiftModule"])
    ]
)
