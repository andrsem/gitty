// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Aliases
import Shared

extension Aliases {
   func description(compact: Bool) -> String {
      let aliases =
         compact
         ? map {
            """
            Name: \($0.name)
            Args: \($0.args.joined(separator: " "))

            """
         }
         : map { $0.description + "\n" }


      return isEmpty
         ? """
         No available aliases.

         To add a new alias use 'open $(gitty --config-path)/aliases.json5' to open and modify the aliases file.
         """
         : """
         ALIASES:

         \(aliases.joined(separator: "\n").trimmedWN)
         """
   }
}



extension Alias: CustomStringConvertible {
   var description: String {
      """
      Name:      \(name)
      Arguments: \(args.joined(separator: " "))
      Details:   \(details)
      Flags:     \(flags.map(\.rawValue).joined(separator: ", "))
      Filters:   \(status.map(\.rawValue).joined(separator: ", "))
      Delay:     \(delay) ms
      Sort:      \(sort)
      """
   }
}
