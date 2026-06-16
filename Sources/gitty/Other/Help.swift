// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import Aliases
import ArgumentParser
import Configurator
import List

let featuresUsage =
   """
   REGEX PATH MATCHING
       gitty --include '2025|2026' --exclude '[Aa]rchive'

   LOGICAL EXPRESSIONS
       |   OR
       &   AND
       !   NOT
       ( ) grouping

       gitty --tags 'backend & (!ux | macOS)'
   """



extension ArgumentHelp {
   enum Gitty {
      static let configPath = ArgumentHelp(
         "Print path to the configuration directory."
      )

      static let regexReference = ArgumentHelp(
         "Print a quick reference for regex path matching."
      )
   }


   enum Status {
      static let layout = ArgumentHelp(
         "Select status layout. (values: \(Configurator.allLayouts().sorted().joined(separator: ", ")))",
         valueName: "name"
      )

      static let scan = ArgumentHelp(
         "Find and show status for repos starting at paths.",
         valueName: "path"
      )
   }


   enum Run {
      static let command = ArgumentHelp(
         "The alias name or shell command to execute.",
         valueName: "alias>|<command"
      )

      static let parallel = ArgumentHelp("Execute commands in parallel.")
      static let quiet = ArgumentHelp("Skip gitty confirmation prompt.")
      static let compact = ArgumentHelp("Print output compactly.")

      static let delay = ArgumentHelp(
         "Delay between sequential commands in milliseconds.",
         valueName: "ms"
      )

      static let sort = ArgumentHelp(
         "Sort the output.",
         valueName: "direction",
      )

      static let aliases = ArgumentHelp("Print available aliases.")
      static let status = ArgumentHelp(
         "Filter repos by status using logical expressions. (values: \(Alias.StatusFilter.allValueStrings.joined(separator: ", ")))",
         valueName: "expr"
      )
   }


   enum List {
      static let add = ArgumentHelp(
         "Add new Git repos to the list.",
         valueName: "path"
      )

      static let scan = ArgumentHelp(
         "Find and print Git repo paths starting at paths.",
         valueName: "path"
      )

      static let scanAdd = ArgumentHelp(
         "Find and add Git repos to the list starting at paths.",
         valueName: "path"
      )

      static let remove = ArgumentHelp(
         "Remove repos from the list matching the path regexes.",
         valueName: "pattern"
      )

      static let verbose = ArgumentHelp("Print the list verbosely.")

      static let addTags = ArgumentHelp(
         "Add one or more new tags.",
         valueName: "tags"
      )

      static let removeTags = ArgumentHelp(
         "Remove one or more tags.",
         valueName: "tags"
      )

      static let retag = ArgumentHelp(
         "Rename tag from <old> to <new>.",
         valueName: "old> <new"
      )
   }


   enum Shared {
      static let depth = ArgumentHelp(
         "Scan depth: 0 = infinity, 1+ = n levels.",
         valueName: "integer"
      )

      static let include = ArgumentHelp(
         "Filter repos by including paths matching regexes.",
         valueName: "pattern"
      )

      static let exclude = ArgumentHelp(
         "Filter repos by excluding paths matching regexes.",
         valueName: "pattern"
      )

      static let tags = ArgumentHelp(
         "Filter repos by tags using logical expressions. Use '\(Tags.reservedTag)' for untagged repos.",
         valueName: "expr"
      )

      static let fixedString = ArgumentHelp(
         "Treat the pattern as a literal string instead of a regex."
      )
   }
}
