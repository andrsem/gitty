// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import Foundation
import List
import SW40
import Shared
import TTS

extension ListMessage {
   func cliDescription(verbose: Bool) -> String {
      let result =
         switch self {
         case let .added(items): msg("added", items, verbose)
         case let .removed(items): msg("removed", items, verbose)
         case .noReposWithPath: "No repos matching the path."
         case .noOldNewForUpdate:
            """
            Error: Expecting 2 arguments for '--retag <old> <new>'
            Help:  --retag <old> <new>  \(ArgumentHelp.List.retag.abstract)
              See 'gitty list --help' for more information.
            """

         case let .tagsAdded(tags, excluded: excludedTags, repos: repos):
            (tags.isEmpty
               ? ""
               : tags.tagAgreementUC + " added: " + tags.tagsActionDescription
                  + "\n" + repos.modifiedAt(verbose))

               + (excludedTags.isEmpty
                  ? ""
                  : "\n" + excludedTags.tagAgreementUC + " not added: "
                     + excludedTags.tagsActionDescription)

         case let .tagsRemoved(tags, excluded: excludedTags, repos: repos):
            (tags.isEmpty
               ? ""
               : tags.tagAgreementUC + " removed: " + tags.tagsActionDescription
                  + "\n" + repos.modifiedAt(verbose))

               + (excludedTags.isEmpty
                  ? ""
                  : "\n" + excludedTags.tagAgreementUC + " not removed: "
                     + excludedTags.tagsActionDescription)

         case let .tagsUpdated(old: old, new: new, repos: repos):
            """
            Tag updated
            from: \([old].tagsActionDescription)
              to: \([new].tagsActionDescription)

            \(repos.modifiedAt(verbose))
            """

         case let .tagsNotUpdated(old, new):
            """
            Tag not updated
            from: \([old].tagsActionDescription)
              to: \([new].tagsActionDescription)
            """
         }

      return result.trimmedWN
   }


   private func msg(
      _ action: String,
      _ list: List,
      _ verbose: Bool
   ) -> String {
      switch list.count {
      case 0:
         "No repos were \(action)."

      case 1:
         "The following repo was \(action):"
            + "\n"
            + list.description(verbose)

      case _:
         "The following \(list.count) repos were \(action):"
            + "\n"
            + list.description(verbose)
      }
   }
}



extension List {
   fileprivate func modifiedAt(_ verbose: Bool) -> String {
      let at = "At: "
      let padding = String(repeating: " ", count: at.count)
      return
         at
         + map { padding + (verbose ? $0.path : $0.url.lastPathComponent) }
         .sorted()
         .joined(separator: "\n")
         .trimmedWN
   }
}



extension Tags {
   fileprivate var tagsActionDescription: Element {
      let reservedTagMsg =
         "\n'\(Self.reservedTag)' is a reserved tag name to represent untagged repos."

      return
         map { $0.styles(.bold) }.joined(separator: " ")
         |> { contains(Self.reservedTag) ? ($0 + reservedTagMsg) : $0 }
   }
}
