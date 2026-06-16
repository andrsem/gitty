// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import Algorithms
import Foundation
import List
import SW40
import Shared
import TTS

extension List {
   func description(_ verbose: Bool) -> String {
      availableTags(verbose)
         + map {
            let line =
               verbose
               ? "\n" + "Repo: ".styles(.faint)
                  + $0.path + "\n"
                  + verboseTagsDescription($0.tags)

               : "• "
                  + $0.url.lastPathComponent
                  + "  "
                  + $0.tags.componentsDescription

            return line.trimming { $0 == " " }
         }
         .sorted(by: azCompare)
         .joined(separator: "\n")
         .trimmedWN
   }


   static func tagsDescription(with tags: Tags, allTags: Tags) -> String {
      """
      \(noReposWithTags(tags))
      \(availableTags(allTags))

      To add tags to an existing repo, use:
        'gitty list --add-tags tag1 tag2 --include <pattern>'

        See 'gitty list --help' for more information.
      """
   }


   static var emptyListDescription: String {
      """
      \(Gitty.logo)
      The list is empty.

      \(Self.addReposHelp)

        See 'gitty list --help' for more information.
      """
   }



   private func verboseTagsDescription(_ tags: Tags) -> String {
      (tags.isEmpty ? "No tags." : "Tags: ").styles(.faint)
         + tags.componentsDescription
   }


   private func availableTags(_ verbose: Bool) -> String {
      verbose
         ? reduce(Set()) { $0.union($1.tags) }
            .sorted(by: azCompare)
            |> {
               $0.isEmpty
                  ? ""
                  : "Available tags: " + $0.componentsDescription + "\n\n"
            }

         : ""
   }


   private static let addReposHelp =
      """
      Add Git repos to the list:
        'gitty list --add <path>...'   - add multiple repos.
        'gitty list --scan-add <path>' - add all found repos starting at path.
      """


   private static func noReposWithTags(_ tags: Tags) -> String {
      "No repos with \(tags.tagAgreementLC): \(tags.componentsDescription)"
   }


   private static func availableTags(_ allTags: Tags) -> String {
      allTags.isEmpty
         ? "No tags available."
         : "Available \(allTags.tagAgreementLC): \(allTags.componentsDescription)"
   }
}
