// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import List

struct Filters: ParsableArguments {
   @Option(
      name: .shortAndLong,
      parsing: .upToNextOption,
      help: .Shared.include,
      completion: .directory,
   )
   var include: [String] = []

   @Option(
      name: .shortAndLong,
      parsing: .upToNextOption,
      help: .Shared.exclude,
      completion: .directory,
   )
   var exclude: [String] = []

   @Flag(
      name: [.long, .customShort("F")],
      help: .Shared.fixedString,
   )
   var fixedString = false

   @Option(name: .shortAndLong, parsing: .upToNextOption, help: .Shared.tags)
   var tags: Tags = []
}
