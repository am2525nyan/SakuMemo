// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SakuMemoPackage",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SakuMemoPackage",
            targets: ["AppFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.19.1"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.10.2"),
        .package(url: "https://github.com/exyte/PopupView", exact: "4.1.7")
    ],
    targets: [
        .target(
            name: "AddMemoFeature",
            dependencies: [.composableArchitecture,"SharedModel","Repository","Utils"]),
        .target(
            name: "AppFeature",
            dependencies: [.composableArchitecture,"MemoFeature","ArchiveFeature"]),
        .target(
            name: "AppIntent",
            dependencies: [.composableArchitecture,"SharedModel"]),
        .target(
            name: "ArchiveFeature",
            dependencies: [.composableArchitecture,"AddMemoFeature","SharedModel","Repository","Components"]),
        .target(
            name: "Components",
            dependencies: ["SharedModel"]),
        .target(
            name: "MemoDetailFeature",
            dependencies: [.composableArchitecture,"SharedModel","Repository"]),
        .target(
            name: "MemoFeature",
            dependencies: [.composableArchitecture,.popupView,"AddMemoFeature","SharedModel","Repository","Components","MemoDetailFeature"]),
        .target(
            name: "RepositoryProtocol",
        dependencies: ["SharedModel"]),
        .target(
            name: "Repository",
            dependencies: [.composableArchitecture,.alamofire,"SharedModel","RepositoryProtocol"]),
        .target(
            name: "SharedModel",
        ),
        .target(
            name: "Utils",
            dependencies: ["SharedModel"]),
       
       

    ]
)
extension Target.Dependency {
    static var composableArchitecture: Self { .product(name: "ComposableArchitecture", package: "swift-composable-architecture") }
    static var alamofire: Self { .product(name: "Alamofire", package: "Alamofire") }
    static var popupView: Self { .product(name: "PopupView", package: "PopupView") }
}

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableUpcomingFeature("InferSendableFromCaptures"))
}
