// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import Configurator
import Foundation
import Layout
import List
import SW40
import StatusLineGen

struct StatusSub: AsyncParsableCommand {
   @OptionGroup
   var filters: Filters

   @Option(
      name: .shortAndLong,
      parsing: .upToNextOption,
      help: .Status.scan,
      completion: .directory,
   )
   var scan: [String] = []

   @Option(name: .shortAndLong, help: .Shared.depth)
   var depth = 3

   @Option(name: .shortAndLong, help: .Status.layout)
   var layout: String = "base"


   func validate() throws {
      try Validator.checkPaths(scan)
      try Validator.checkDepth(depth)
   }


   func run() async throws {
      scan.isEmpty
         ? try await printStatus()
         : try await scanAndShow(at: scan)
   }


   static let configuration = CommandConfiguration(
      commandName: "status",
      abstract: "Show the status of managed Git repos.",
      usage: """
         gitty status [--include <pattern>...] [--exclude <pattern>...] [--fixed-string] [--tags <expr>...] [--layout <name>]
         gitty status [--scan <path>...] [--depth <integer>] [--layout <name>]
         """,
      discussion: featuresUsage,
      aliases: ["s"],
   )
}



extension StatusSub {
   private func printStatus() async throws {
      let list = try Configurator.readList()
      try list.throwIfEmpty()
      let urls =
         try list
         .filtered(
            tags: filters.tags,
            includedPaths: filters.include,
            excludedPaths: filters.exclude,
            fixedString: filters.fixedString,
         )
         .map(\.url)

      let status = try await getStatus(for: urls, with: layout)

      print(status)
   }



   private func scanAndShow(at paths: [String]) async throws {
      var urls: [URL] = []
      for path in paths {
         await urls += Configurator.findGitRepoURLs(at: path, depth: depth)
      }

      let result =
         try await getStatus(for: urls, with: layout)
         .ifEmpty(
            """
            No repos found at depth: \(depth) starting at path:
            \(paths.joined(separator: "\n"))
            """
         )

      print(result)
   }
}



private func getStatus(
   for urls: [URL],
   with layout: String,
) async throws -> String {
   let layout = try Configurator.readLayout(layout)
   let lineID = { (l1: StatusLine, l2: StatusLine) in
      layout.aZSort
         ? l1.sortID < l2.sortID
         : l1.sortID > l2.sortID
   }

   return
      try await urls
      .unorderedCompactPMap(maxTasks: tasksLimit()) {
         try await getStatusLine(at: $0, with: layout)
      }
      .sorted(by: lineID)
      .reduce(into: "") { $0.append($1.line + "\n") }
      .dropLast()
      |> String.init
}



private func getStatusLine(
   at repoDir: URL,
   with layout: Layout,
) async throws -> StatusLine? {
   let customCommands = layout.customCommands
   let statusAsInput = customCommands.contains(where: \.statusAsInput)
   let _generateStatusLine = { (repoDir, $0, $1, $2) |> generateStatusLine }
   let _getCustomOutputs = {
      try await (repoDir, customCommands, $0) |> getCustomOutputs
   }

   let _getStatus = {
      let containsIgnored = layout.components.contains {
         if case .ignored = $0 { true } else { false }
      }
      return try await (repoDir, containsIgnored) |> Configurator.getStatus
   }

   let printError = {
      print(repoDir.path(percentEncoded: false), $0, separator: "\n")
   }

   do {
      switch (layout.executionMode, statusAsInput) {
      case (_, true):
         let (status, error, input) = try await _getStatus()
         let custom = try await _getCustomOutputs(input)
         if !error.isEmpty { printError(error) }
         return _generateStatusLine(layout, status, custom)

      case (.parallel, false):
         async let (status, error, _) = try await _getStatus()
         async let custom = try await _getCustomOutputs("")
         if try await !error.isEmpty { printError(try await error) }
         return try await _generateStatusLine(layout, status, custom)

      case (.statusThenCustom, false):
         let (status, error, _) = try await _getStatus()
         let custom = try await _getCustomOutputs("")
         if !error.isEmpty { printError(error) }
         return _generateStatusLine(layout, status, custom)

      case (.customThenStatus, false):
         let custom = try await _getCustomOutputs("")
         let (status, error, _) = try await _getStatus()
         if !error.isEmpty { printError(error) }
         return _generateStatusLine(layout, status, custom)
      }
   } catch {
      printError(error)
      return nil
   }
}



private func getCustomOutputs(
   for repoDir: URL,
   commands: [Layout.CustomCommand],
   input: String,
) async throws -> [CustomOutput] {
   guard !commands.isEmpty else { return [] }

   var results: [(String, (output: String, error: String))] = []
   results.reserveCapacity(commands.count)
   for cmd in commands {
      results.append(
         try await run(
            cmd.command,
            repoDir,
            cmd.statusAsInput ? input : "",
         )
      )
   }

   var customOutput: [CustomOutput] = []
   customOutput.reserveCapacity(commands.count)
   return results.reduce(into: customOutput) {
      $0.append(($1.0, $1.1.output + $1.1.error))
   }
}



private func run(
   _ command: String,
   _ repoDir: URL,
   _ input: String,
) async throws -> (commandName: String, (output: String, error: String)) {
   try await Configurator
      .run([command], at: repoDir, input: input)
      |> { (command, $0) }
}
