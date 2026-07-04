// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AirbnbDatePicker",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "AirbnbDatePicker", targets: ["AirbnbDatePicker"])
    ],
    targets: [
        .target(
            name: "AirbnbDatePicker",
            path: "AirbnbDatePicker/Classes"
        )
    ]
)
