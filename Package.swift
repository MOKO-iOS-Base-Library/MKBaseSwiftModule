// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MKBaseSwiftModule",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "MKBaseSwiftModule",
            type: .dynamic,
            targets: ["MKBaseSwiftModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/devicekit/DeviceKit.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/WenchaoD/FSCalendar.git", .upToNextMajor(from: "2.8.4")),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", .upToNextMajor(from: "6.5.0")),
        .package(url: "https://github.com/CoderMJLee/MJRefresh.git", .upToNextMajor(from: "3.7.6")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.6.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/raulriera/TextFieldEffects.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/scalessec/Toast-Swift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.16"),
        .package(url: "https://github.com/jmcnamara/libxlsxwriter", from: "1.2.3"),
    ],
    targets: [
        .target(
            name: "MKBaseSwiftModule",
            dependencies: [
                .product(name: "DeviceKit", package: "DeviceKit"),
                .product(name: "FSCalendar", package: "FSCalendar"),
                .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
                .product(name: "MJRefresh", package: "MJRefresh"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "TextFieldEffects", package: "TextFieldEffects"),
                .product(name: "Toast", package: "Toast-Swift"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "libxlsxwriter", package: "libxlsxwriter")
            ],
            path: "Sources",
            resources: [
                .process("Assets")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("IOS16_OR_LATER")
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
