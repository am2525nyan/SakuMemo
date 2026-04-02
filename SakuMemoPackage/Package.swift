// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SakuMemoPackage",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "AppFeature", targets: ["AppFeature"]),
                .library(name: "AddMemoFeature", targets: ["AddMemoFeature"]),
                .library(name: "MemoFeature", targets: ["MemoFeature"]),
                .library(name: "ArchiveFeature", targets: ["ArchiveFeature"]),
                .library(name: "MemoDetailFeature", targets: ["MemoDetailFeature"]),
                .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
                .library(name: "SubscriptionFeature", targets: ["SubscriptionFeature"]),
                .library(name: "SharedModel", targets: ["SharedModel"]),
                .library(name: "Repository", targets: ["Repository"]),
                .library(name: "RepositoryProtocol", targets: ["RepositoryProtocol"]),
                .library(name: "Utils", targets: ["Utils"]),
                .library(name: "Components", targets: ["Components"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.25.4"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.10.2"),
        .package(url: "https://github.com/exyte/PopupView", exact: "4.1.7"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "12.0.0"),
//        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", exact: "11.13.0"),
    ],
    targets: [
        .target(
            name: "AddMemoFeature",
            dependencies: [.composableArchitecture, "SharedModel", "Repository", "RepositoryProtocol", "Utils"]
        ),
        .target(
            name: "AppFeature",
            dependencies: [.composableArchitecture, "MemoFeature", "ArchiveFeature", "SettingsFeature", "Components", "Utils"]
        ),
        .target(
            name: "AppIntent",
            dependencies: [.composableArchitecture, "SharedModel", "Repository", "RepositoryProtocol"]
        ),
        .target(
            name: "ArchiveFeature",
            dependencies: [.composableArchitecture, "AddMemoFeature", "SharedModel", "Repository", "Components"]
        ),
        .target(
            name: "Components",
            dependencies: ["SharedModel", "Utils"]
        ),
        .target(
            name: "MemoDetailFeature",
            dependencies: [.composableArchitecture, "SharedModel", "Repository","Utils"]
        ),
        .target(
            name: "MemoFeature",
            dependencies: [.composableArchitecture, .popupView, "AddMemoFeature", "SharedModel", "Repository", "Components", "MemoDetailFeature", "SubscriptionFeature", "Utils"]
        ),
        .target(
            name: "RepositoryProtocol",
            dependencies: ["SharedModel"]
        ),
        .target(
            name: "Repository",
            dependencies: [.composableArchitecture, .alamofire, .firebaseAI, .FirebaseAppCheck, "SharedModel", "RepositoryProtocol"]
        ),
        .target(
            name: "SharedModel"
        ),
        .target(
            name: "SubscriptionFeature",
            dependencies: [.composableArchitecture, "SharedModel", "Repository", "RepositoryProtocol"]
        ),
        .target(
            name: "Utils",
            dependencies: ["SharedModel"]
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [.composableArchitecture]
        )
    ]
)
extension Target.Dependency {
    static var composableArchitecture: Self { .product(name: "ComposableArchitecture", package: "swift-composable-architecture") }
    static var alamofire: Self { .product(name: "Alamofire", package: "Alamofire") }
    static var popupView: Self { .product(name: "PopupView", package: "PopupView") }
    static var firebaseAI: Self { .product(name: "FirebaseAI", package: "firebase-ios-sdk") }
    static var FirebaseAppCheck: Self { .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk") }
    static var googleMobileAds: Self { .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads") }
}

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableUpcomingFeature("InferSendableFromCaptures"))
}
