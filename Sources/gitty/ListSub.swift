// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import Configurator
import Foundation
import List
import SW40
import Shared
import TTS

struct ListSub: AsyncParsableCommand {
   @OptionGroup
   var filters: Filters

   @Option(
      name: .shortAndLong,
      parsing: .upToNextOption,
      help: .List.scan,
      completion: .directory
   )
   var scan: [String] = []

   @Option(
      name: [.long, .customShort("A")],
      parsing: .upToNextOption,
      help: .List.scanAdd,
      completion: .directory
   )
   var scanAdd: [String] = []

   @Option(name: .shortAndLong, help: .Shared.depth)
   var depth = 3

   @Option(
      name: .shortAndLong,
      parsing: .upToNextOption,
      help: .List.add,
      completion: .directory
   )
   var add: [String] = []

   @Option(
      name: .shortAndLong,
      parsing: .upToNextOption,
      help: .List.remove,
      completion: .directory
   )
   var remove: [String] = []

   @Option(
      parsing: .upToNextOption,
      help: .List.addTags
   )
   var addTags: Tags = []

   @Option(
      parsing: .upToNextOption,
      help: .List.removeTags
   )
   var removeTags: Tags = []

   @Option(
      parsing: .upToNextOption,
      help: .List.retag
   )
   var retag: Tags = []

   @Flag(name: .shortAndLong, help: .List.verbose)
   var verbose = false



   func validate() throws {
      try (add, remove, scan, scanAdd, addTags, removeTags, retag)
         |> Validator.checkListActions
      try Validator.checkPaths(add, wherePath: .isGit)
      try Validator.checkPaths(scan + scanAdd)
      try Validator.checkDepth(depth)
      try [addTags, removeTags, retag].forEach(Validator.checkTags)
   }


   func run() async throws {
      // swift-format-ignore
      if !add.isEmpty             { try addRepos(at: add)               }
      else if !remove.isEmpty     { try removeRepos(at: remove)         }
      else if !scan.isEmpty       { await scanForRepos(at: scan)        }
      else if !scanAdd.isEmpty    { try await scanAddRepos(at: scanAdd) }
      else if !addTags.isEmpty    { try tagsAdd()                       }
      else if !removeTags.isEmpty { try tagsRemove()                    }
      else if !retag.isEmpty      { try tagUpdate()                     }
      else                        { try printList()                     }
   }


   static let configuration = CommandConfiguration(
      commandName: "list",
      abstract: "Manage the list of Git repos.",
      usage: """
         gitty list [--include <pattern>...] [--exclude <pattern>...] [--fixed-string] [--tags <expr>...] [--verbose]
         gitty list [--scan <path>...] [--depth <integer>]
         gitty list [--scan-add <path>...] [--depth <integer>] [--verbose]
         gitty list [--add <path>...] [--verbose]
         gitty list [--remove <pattern>...] [--fixed-string] [--verbose]
         gitty list [--add-tags <tags>...] [--include <pattern>...] [--exclude <pattern>...] [--fixed-string] [--verbose]
         gitty list [--remove-tags <tags>...] [--include <pattern>...] [--exclude <pattern>...] [--fixed-string] [--verbose]
         gitty list [--retag <old> <new>] [--include <pattern>...] [--exclude <pattern>...] [--fixed-string] [--verbose]
         """,
      discussion: featuresUsage,
      aliases: ["l"]
   )
}



extension ListSub {
   private var path: [String] { filters.include }
   private var excludedPaths: [String] { filters.exclude }
   private var fixedString: Bool { filters.fixedString }
   private var tags: [String] { filters.tags }


   private func printList() throws {
      let list = try Configurator.readList()
      try list.throwIfEmpty()
      let result =
         try list
         .filtered(
            tags: tags,
            includedPaths: path,
            excludedPaths: excludedPaths,
            fixedString: filters.fixedString
         )
         .description(verbose)

      print(result)
   }


   private func addRepos(at paths: [String]) throws {
      try saveResultOf(verbose: verbose) {
         paths.map { Repo.init($0) } |> $0.adding
      }
   }


   private func scanForRepos(at paths: [String]) async {
      var urls: [URL] = []
      for path in paths {
         urls += await Configurator.findGitRepoURLs(at: path, depth: depth)
      }

      let message =
         urls.map { Repo($0.path()).path }
         .sorted(by: azCompare)
         .joined(separator: "\n")
         .ifEmpty(
            """
            No repos were found at a depth of \(depth) at:
            \(paths.joined(separator: "\n"))
            """
         )

      print(message)
   }


   private func scanAddRepos(at paths: [String]) async throws {
      var urls: [URL] = []
      for path in paths {
         urls += await Configurator.findGitRepoURLs(at: path, depth: depth)
      }

      let foundRepos = urls.map { Repo($0.path()) }

      try saveResultOf(verbose: verbose) { $0.adding(foundRepos) }
   }


   private func removeRepos(at paths: [String]) throws {
      try saveResultOf(verbose: verbose) { currentList in
         try currentList.throwIfEmpty()

         let (remaining, removedRepos) =
            try paths.reduce(into: (remained: currentList, removed: List())) {
               let result = try $0.remained
                  .removing($1, fixedString: fixedString)
               $0.remained = result.list
               if case let .removed(repos) = result.message {
                  $0.removed += repos
               }
            }

         if !removedRepos.isEmpty {
            let repoAgreement = removedRepos.count == 1 ? "repo" : "repos"
            print(
               """
               Do you want to remove the following \(repoAgreement):
               \(removedRepos.description(verbose))

               """
            )
            try yesConfirmation()
         }

         return (remaining, .removed(removedRepos))
      }
   }


   private func tagsAdd() throws {
      try saveResultOf(verbose: verbose) {
         try $0.throwIfEmpty()
         return try $0.addingTags(
            addTags,
            includedPaths: path,
            excludedPaths: excludedPaths
         )
      }
   }


   private func tagsRemove() throws {
      try saveResultOf(verbose: verbose) {
         try $0.throwIfEmpty()
         return try $0.removingTags(
            removeTags,
            includedPaths: path,
            excludedPaths: excludedPaths
         )
      }
   }


   private func tagUpdate() throws {
      try saveResultOf(verbose: verbose) {
         try $0.throwIfEmpty()
         return try $0.updatingTags(
            retag,
            includedPaths: path,
            excludedPaths: excludedPaths
         )
      }
   }
}



private func saveResultOf(
   verbose: Bool = false,
   _ action: (List) throws -> (List, ListMessage),
) throws {
   let (updatedList, message) = try Configurator.readList() |> action
   try Configurator.writeList(updatedList)
   print(message.cliDescription(verbose: verbose))
}
