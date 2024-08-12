// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "flex-scroll",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "FlexScroll",
            targets: ["FlexScroll"]
        )
    ],
    targets: [
        .target(
            name: "FlexScroll"
        ),
    ]
)
