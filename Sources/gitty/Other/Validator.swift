// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import Configurator
import List
import Shared
import TTS

enum Validator {
   static func checkDepth(_ depth: Int?) throws {
      guard let depth else { return }
      guard depth >= .zero else {
         throw CleanExit.message("Depth should be a non-negative integer.")
      }
   }


   static func checkPaths(
      _ paths: [String?],
      wherePath type: PathType = .isAny,
   ) throws {
      let (invalidPaths, notGitPaths) = Configurator.validatePaths(paths)
      let notGitRepos = type == .isGit ? notGitPaths : []

      guard (invalidPaths + notGitRepos).isEmpty else {
         let notExists =
            invalidPaths
            .map { "Path does not exist: \($0)" }
            .joined(separator: "\n")

         let notGitRepo =
            notGitRepos.isEmpty
            ? ""
            : (notExists.isEmpty ? "" : "\n")
               + notGitRepos
               .map { "Path is not a Git repo: \($0)" }
               .joined(separator: "\n")

         throw CleanExit.message(notExists + notGitRepo)
      }
   }


   enum PathType {
      case isGit
      case isAny
   }


   static func checkTags(_ tags: Tags) throws {
      let trimmed = tags.map(\.trimmedWN)
      let tagsWithIllegalCharacters =
         trimmed.filter {
            $0.contains {
               $0.isWhitespace
                  || $0 == Character.not
                  || $0 == Character.and
                  || $0 == Character.or
                  || $0 == Character.openParen
                  || $0 == Character.closeParen
            }
         }

      guard !trimmed.contains(""), tagsWithIllegalCharacters.isEmpty else {
         let message =
            "Tags should not contain illegal characters like: whitespace, '\(Character.or)', '\(Character.and)', '\(Character.not)', '\(Character.openParen)', '\(Character.closeParen)'"
            + "\n"
            + tagsWithIllegalCharacters
            .map { "'\($0.styles(.bold))'" }
            .joined(separator: " ")

         throw CleanExit.message(message)
      }
   }


   static func checkListActions(
      _ add: [String],
      _ remove: [String],
      _ scan: [String],
      _ scanAdd: [String],
      _ addTags: [String],
      _ removeTags: [String],
      _ retag: [String],
   ) throws {
      let actions: [(String, any Collection)] = [
         ("--add", add),
         ("--remove", remove),
         ("--scan", scan),
         ("--scan-add", scanAdd),
         ("--add-tags", addTags),
         ("--remove-tags", removeTags),
         ("--retag", retag),
      ]
      .filter { !$0.1.isEmpty }

      if actions.count > 1 {
         throw CleanExit.message(
            """
            Error: Multiple list actions (\(actions.map(\.0).joined(separator: ", "))) are not allowed at the same time.
            Usage: \(ListSub.usageString().replacing("\n", with: "\n       "))
              See 'gitty list --help' for more information.
            """
         )
      }
   }



   static func checkRunMissingCommandArg(_ isMissing: Bool) throws {
      if isMissing {
         let valueName = ArgumentHelp.Run.command.valueName ?? "command"
         let missingArg = """
            Error: Missing expected argument '<\(valueName)>'
            Help:  <\(valueName)>  \(ArgumentHelp.Run.command.abstract)
            Usage: \(RunSub.usageString().replacing("\n", with: "\n       "))

              See 'gitty run --help' for more information.
            """

         throw CleanExit.message(missingArg)
      }
   }


   static func checkDelay(_ delay: Int) throws {
      let minDelay = 0
      let maxDelay = 3_600_000
      guard (minDelay ... maxDelay) ~= delay else {
         throw
            CleanExit
            .message(
               "Delay should be in range from \(minDelay) to \(maxDelay) milliseconds."
            )
      }
   }
}
