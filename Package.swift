// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Slite",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Slite",
            targets: ["Slite"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", from: "8.0.0"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift.git", from: "4.0.0"),
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Slite",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "Sentry", package: "sentry-cocoa"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "SwiftUIX", package: "SwiftUIX")
            ]),
        .testTarget(
            name: "SliteTests",
            dependencies: ["Slite"]),
    ]
)