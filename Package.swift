import PackageDescription

let package = Package(
    name: "flex-scroll",
    platforms: [
        .iOS(.v15)
    ]
    products: [
        .library(
            name: "flex-scroll",
            targets: ["flex-scroll"]
        )
    ]
    targets: [
        .target(
            name: "flex-scroll"
        ),
    ]
)
