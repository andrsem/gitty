// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package import Foundation
import Subprocess

#if canImport(System)
   import System
#else
   import SystemPackage
#endif

package enum Shell {
   /// - WARNING: First argument is treated as command string and subsequent arguments are treated as positional parameters
   package static func run(
      _ args: [String],
      at workingDirectory: URL = URL.homeDirectory,
      environment: [String: String]? = nil,
      input: String = ""
   ) async throws -> (output: String, error: String) {
      let envKey = Environment.Key.init(stringLiteral:)
      let environment =
         environment
         .map { $0.map { (envKey($0.key), $0.value) } }
         .map(Dictionary.init)
         .map(Environment.custom)
         ?? .inherit

      let result = try await Subprocess.run(
         .name("sh"),
         arguments: .init(["-c"] + args),
         environment: environment,
         workingDirectory: .init(workingDirectory.path(percentEncoded: false)),
         input: .string(input),
         output: .string(limit: outputSize),
         error: .string(limit: errorSize),
      )

      return (result.standardOutput ?? "", result.standardError ?? "")
   }


   package static func runGit(
      _ args: [String],
      at workingDirectory: URL,
   ) async throws -> (output: String, error: String) {
      let result = try await Subprocess.run(
         .name("git"),
         arguments: .init(args),
         workingDirectory: .init(workingDirectory.path(percentEncoded: false)),
         output: .string(limit: outputSize),
         error: .string(limit: errorSize),
      )

      return (result.standardOutput ?? "", result.standardError ?? "")
   }
}


private let outputSize =
   ProcessInfo.processInfo
   .environment["GITTY_OUTPUT_SIZE_KB"]
   .flatMap(Int.init)
   .map(\.kb)
   ?? 2.mb


private let errorSize =
   ProcessInfo.processInfo
   .environment["GITTY_ERROR_SIZE_KB"]
   .flatMap(Int.init)
   .map(\.kb)
   ?? 128.kb



extension Int {
   /// kilobytes in bytes
   var kb: Self { self * 1024 }
   /// megabytes in bytes
   var mb: Self { self.kb * 1024 }
}
