// swift-tools-version: 6.2
// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import PackageDescription

extension String {
   static let aliases = "Aliases"
   static let configurator = "Configurator"
   static let gitty = "gitty"
   static let io = "IO"
   static let layout = "Layout"
   static let list = "List"
   static let shared = "Shared"
   static let status = "Status"
   static let statusLineGen = "StatusLineGen"

   var tests: Self { self + "Tests" }
}



extension Target.Dependency {
   static var aliases: Self { target(name: .aliases) }
   static var algorithms: Self {
      product(name: "Algorithms", package: "swift-algorithms")
   }
   static var argumentParser: Self {
      product(name: "ArgumentParser", package: "swift-argument-parser")
   }
   static var configurator: Self { target(name: .configurator) }
   static var diffy: Self { product(name: "Diffy", package: "Diffy") }
   static var gitty: Self { target(name: .gitty) }
   static var io: Self { target(name: .io) }
   static var layout: Self { target(name: .layout) }
   static var list: Self { target(name: .list) }
   static var shared: Self { target(name: .shared) }
   static var status: Self { target(name: .status) }
   static var statusLineGen: Self { target(name: .statusLineGen) }
   static var subprocess: Self {
      product(name: "Subprocess", package: "swift-subprocess")
   }
   static var sw40: Self { product(name: "SW40", package: "SW40") }
   static var tts: Self { product(name: "TTS", package: "TTS") }
}



private let settings: [SwiftSetting] = [
   .enableUpcomingFeature("ExistentialAny"),
   .enableUpcomingFeature("InternalImportsByDefault"),
   .enableUpcomingFeature("MemberImportVisibility"),
   .enableUpcomingFeature("InferIsolatedConformances"),
   .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
   .strictMemorySafety(),
]



let package = Package(
   name: "gitty",
   platforms: [.macOS(.v13)],
   dependencies: [
      .package(
         url: "https://github.com/apple/swift-algorithms.git",
         exact: "1.2.1",
      ),
      .package(
         url: "https://github.com/apple/swift-argument-parser",
         exact: "1.8.2",
      ),
      .package(
         url: "https://github.com/swiftlang/swift-subprocess.git",
         exact: "0.5.0",
      ),
      .package(
         url: "https://github.com/andrsem/sw40",
         exact: "1.0.0",
      ),
      .package(
         url: "https://github.com/andrsem/tts",
         exact: "1.0.0",
      ),
      .package(
         url: "https://github.com/andrsem/diffy",
         exact: "1.0.0",
      ),
   ],
   targets: [
      // MARK: - gitty cli

      .executableTarget(
         name: .gitty,
         dependencies: [
            .aliases,
            .algorithms,
            .argumentParser,
            .configurator,
            .list,
            .shared,
            .status,
            .statusLineGen,
            .tts,
         ],
         swiftSettings: settings,
      ),
      .testTarget(
         name: .gitty.tests,
         dependencies: [.aliases, .argumentParser, .gitty, .sw40],
         swiftSettings: settings,
      ),
      .testTarget(
         name: "E2ETests",
         dependencies: [.configurator, .diffy, .io, .shared, .sw40, .tts],
         swiftSettings: settings,
      ),


      .target(
         name: .statusLineGen,
         dependencies: [.algorithms, .layout, .shared, .status, .sw40, .tts],
         swiftSettings: settings,
      ),
      .testTarget(
         name: .statusLineGen.tests,
         dependencies: [
            .diffy,
            .layout,
            .shared,
            .status,
            .statusLineGen,
            .sw40,
            .tts,
         ],
         swiftSettings: settings,
      ),


      // MARK: - configurator

      .target(
         name: .configurator,
         dependencies: [.aliases, .io, .layout, .list, .status],
         resources: [.embedInCode("Resources")],
         swiftSettings: settings,
      ),
      .testTarget(
         name: .configurator.tests,
         dependencies: [.aliases, .configurator, .list, .layout, .diffy],
         swiftSettings: settings,
      ),


      // MARK: - gitty core

      .target(
         name: .aliases,
         dependencies: [.algorithms, .shared, .sw40],
         swiftSettings: settings,
      ),
      .testTarget(
         name: .aliases.tests,
         dependencies: [.aliases, .diffy, .shared],
         resources: [.embedInCode("TestResources")],
         swiftSettings: settings,
      ),


      .target(
         name: .io,
         dependencies: [.sw40, .subprocess],
         swiftSettings: settings,
      ),
      .testTarget(
         name: .io.tests,
         dependencies: [.io],
         resources: [.process("TestResources")],
         swiftSettings: settings,
      ),


      .target(
         name: .layout,
         dependencies: [.shared, .sw40],
         swiftSettings: settings,
      ),
      .testTarget(
         name: .layout.tests,
         dependencies: [.diffy, .layout, .shared, .sw40],
         resources: [.embedInCode("TestResources")],
         swiftSettings: settings,
      ),


      .target(
         name: .list,
         dependencies: [.algorithms, .shared, .sw40],
         swiftSettings: settings,
      ),
      .testTarget(
         name: .list.tests,
         dependencies: [.diffy, .list, .shared, .sw40],
         swiftSettings: settings,
      ),


      .target(
         name: .shared,
         dependencies: [.algorithms],
         swiftSettings: settings,
      ),
      .testTarget(
         name: .shared.tests,
         dependencies: [.shared],
         swiftSettings: settings,
      ),


      .target(
         name: .status,
         dependencies: [.shared, .sw40],
         swiftSettings: settings,
      ),
      .testTarget(
         name: .status.tests,
         dependencies: [.diffy, .status],
         swiftSettings: settings,
      ),

   ],
)
