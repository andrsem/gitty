// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Aliases
import ArgumentParser
import Configurator
import Foundation
import List
import SW40
import Shared
import Status
import TTS

struct RunSub: AsyncParsableCommand {
   @Argument(parsing: .allUnrecognized, help: .Run.command)
   var command: [String] = []

   @Flag(name: .shortAndLong, help: .Run.aliases)
   var aliases = false

   @OptionGroup
   var filters: Filters

   @Option(
      name: [.short, .customLong("status")],
      parsing: .upToNextOption,
      help: .Run.status,
      completion: .list(Alias.StatusFilter.allValueStrings),
   )
   var statusFilters: [String] = []

   @Option(name: .shortAndLong, help: .Run.delay)
   var delay = 0

   @Option(
      name: [.long, .customShort("S")],
      help: .Run.sort,
      completion: .list(OutputSort.allValueStrings),
   )
   var sort: OutputSort = .az

   @Flag(name: .shortAndLong, help: .Run.compact)
   var compact = false

   @Flag(name: .shortAndLong, help: .Run.parallel)
   var parallel = false

   @Flag(name: .shortAndLong, help: .Run.quiet)
   var quiet = false


   func validate() throws {
      try Validator.checkRunMissingCommandArg(!aliases && command.isEmpty)
      try Validator.checkDelay(delay)
   }


   func run() async throws {
      switch aliases {
      case true: try printAliases()
      case false: try await printCommandResult()
      }
   }


   static let configuration = CommandConfiguration(
      commandName: "run",
      abstract: "Execute aliases or shell commands on managed repos.",
      usage: """
         gitty run [--aliases] [--compact]
         gitty run <alias>|<command> [--include <pattern>...] [--exclude <pattern>...] [--fixed-string] [--tags <expr>...] [--status <expr>...] [--delay <ms>] [--sort <direction>] [--compact] [--parallel] [--quiet]
         """,
      discussion:
         """
         \("WARNING:".fg(.red).styles(.bold)) Review commands carefully before execution. Some commands may modify or damage your repos.

         \(featuresUsage)
             gitty run 'pwd' --status 'added | !modified'
         """,
      aliases: ["r"],
   )
}



extension OutputSort: ExpressibleByArgument {}
extension Alias.StatusFilter: ExpressibleByArgument {}



extension RunSub {
   private func printAliases() throws {
      print(try Configurator.readAliases().description(compact: compact))
   }


   private func printCommandResult() async throws {
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

      let selectedCmd = try selectCommand()
      let containsFlag = { selectedCmd.flags.contains($0) }

      let compact = containsFlag(.compact) ? true : compact
      let parallel = containsFlag(.parallel) ? true : parallel
      let quiet = containsFlag(.quiet) ? true : quiet

      if !quiet {
         print(
            """
            \(selectedCmd.type.rawValue.uppercased()) will be executed:

            \(selectedCmd.args.joined(separator: " "))

            """
         )
         try yesConfirmation()
         print("")
      }

      try await runCommands(
         at: urls,
         in: parallel,
         delay: selectedCmd.delay,
         sort: selectedCmd.sort,
      ) {
         try await getCommandResult(
            running: selectedCmd.args,
            at: $0,
            compact: compact,
            statusFilters: selectedCmd.statusFilters,
         )
      }
   }


   private typealias SelectedCmd =
      (
         args: [String],
         type: CommandType,
         flags: [Alias.Flag],
         statusFilters: [String],
         delay: Int,
         sort: OutputSort
      )


   private enum CommandType: String { case alias, command }


   private func selectCommand() throws -> SelectedCmd {
      let cmd: SelectedCmd = (
         command, .command, [], statusFilters, delay, sort,
      )

      let alias: SelectedCmd? =
         try Configurator
         .readAliases()
         .first { $0.name == command.first }
         .map(mergedAlias)
         .map {
            (
               $0.args,
               .alias,
               $0.flags,
               $0.status.map(\.rawValue),
               $0.delay,
               $0.sort,
            )
         }

      return alias ?? cmd
   }


   private func mergedAlias(_ alias: Alias) throws -> Alias {
      let selectedFlags: [Alias.Flag] =
         [.compact: compact, .parallel: parallel, .quiet: quiet]
         .filter(\.value)
         .map(\.key)

      let mergedArgs = alias.args + command.dropFirst()
      let mergedFlags = Set(alias.flags + selectedFlags) |> Array.init
      let mergedStatusFilters =
         try (alias.status + statusFilters.map(statusFilter))
         |> Set.init
         |> Array.init

      func hasArgs(_ short: String, _ long: String) -> Bool {
         let args = CommandLine.arguments.dropFirst()
         return args.contains(short)
            || args.contains(long)
            || args.contains { $0.hasPrefix("\(short)=") }
            || args.contains { $0.hasPrefix("\(long)=") }
      }

      let mergedSort = hasArgs("-S", "--sort") ? sort : alias.sort
      let mergedDelay = hasArgs("-d", "--delay") ? delay : alias.delay

      return try Alias(
         alias.name,
         args: mergedArgs,
         details: alias.details,
         flags: mergedFlags,
         status: mergedStatusFilters,
         delay: mergedDelay,
         sort: mergedSort,
      )
   }
}


private func runCommands(
   at urls: [URL],
   in parallel: Bool,
   delay: Int,
   sort: OutputSort,
   action: @escaping @Sendable (URL) async throws -> String?,
) async throws {
   guard !urls.isEmpty else { return }

   var outputs: [String] = []
   outputs.reserveCapacity(urls.count)

   if parallel {
      let results =
         try await urls
         .unorderedCompactPMap(maxTasks: tasksLimit(), action)

      switch sort {
      case .az, .za: outputs.append(contentsOf: results)
      case .unsorted: results.forEach { print($0) }
      }
   } else {
      for (offset, url) in urls.enumerated() {
         if delay > .zero && offset > .zero {
            try await Task.sleep(for: .milliseconds(delay))
         }
         guard let result = try await action(url) else { continue }

         switch sort {
         case .az, .za: outputs.append(result)
         case .unsorted: print(result)
         }
      }
   }

   guard sort != .unsorted else { return }

   let result =
      outputs
      .sorted {
         let isAZ = $0.azCompare($1)
         return sort == .az ? isAZ : !isAZ
      }
      .joined(separator: "\n")

   print(result)
}


private func getCommandResult(
   running command: [String],
   at url: URL,
   compact: Bool,
   statusFilters: [String],
) async throws -> String? {
   guard try await satisfiesAny(statusFilters, at: url) else {
      return nil
   }

   let repoHeader = "# gitty.repo " + url.lastPathComponent
   let (output, error) = try await Configurator.run(command, at: url)
   let err =
      error.isEmpty
      ? ""
      : repoHeader + " " + error

   let result =
      switch (output.isEmpty, error.isEmpty) {
      case (true, false): err
      case (false, false): output + err
      case (_, true): output
      }

   return compact
      ? result.trimmingSuffix("\n") |> String.init
      : repoHeader + (result.isEmpty ? "" : "\n") + result
}



private func satisfiesAny(
   _ statusFilters: [String],
   at url: URL,
) async throws -> Bool {
   guard !statusFilters.isEmpty else { return true }

   let expressions = try statusFilters.map { str in
      try parseExpression(str, parseValue: statusFilter)
   }

   let needsIgnored = statusFilters.contains(
      Alias.StatusFilter.ignored.rawValue
   )
   let status =
      try await Configurator
      .getStatus(for: url, ignored: needsIgnored)
      .status
   let changes = status.changedEntries
   let subChanges = changes.hasSubmoduleChanges()

   return evaluate(Expression.or(expressions)) { filter in
      switch filter {
      case .added: changes.containsChange(.added)
      case .copied: changes.containsChange(.copied)
      case .deleted: changes.containsChange(.deleted)
      case .detached: status.isDetached
      case .ignored: changes.containsIgnored()
      case .initialCommit: status.isInitialCommit
      case .locked: status.isLocked
      case .modified: changes.containsChange(.modified)
      case .needsPull: status.needsPull
      case .needsPush: status.needsPush
      case .needsUpstream: status.needsUpstream
      case .clean: status.isClean
      case .renamed: changes.containsChange(.renamed)
      case .submodule: changes.containsSubmodule()
      case .subCommitChange: subChanges.commit
      case .subModified: subChanges.modified
      case .subUntracked: subChanges.untracked
      case .typeChange: changes.containsChange(.typeChange)
      case .unmerged: changes.containsChange(.unmerged)
      case .untracked: changes.containsUntracked()
      }
   }
}



private func statusFilter(from raw: String) throws -> Alias.StatusFilter {
   let invalidFilterMessage = {
      """
      The value '\(raw)' is invalid for '--status <expr>'. Please provide one of \(Alias.StatusFilter.allCases.map{ "'" + $0.rawValue + "'"}.joined(separator: ", ")).

      Help:  --status <expr>  Filter repos by status using logical expressions.
      Usage: \(RunSub.usageString().split(separator: "\n").joined(separator: "\n       "))
        See 'gitty \(RunSub._commandName) --help' for more information.
      """
   }

   guard let filter = Alias.StatusFilter(rawValue: raw) else {
      throw CleanExit.message(invalidFilterMessage())
   }

   return filter
}
