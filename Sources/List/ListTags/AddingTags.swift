// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import SW40
import Shared

extension List {
   /// After adding, tags are sorted A-Z.
   package func addingTags(
      _ tags: Tags,
      includedPaths: [String],
      excludedPaths: [String] = [],
   ) throws -> (list: Self, message: ListMessage) {
      try tagsAction(includedPaths, excludedPaths: excludedPaths) {
         _addingTags($0, tags)
      }
   }


   private func _addingTags(
      _ reposToAddTags: [Repo],
      _ tags: Tags,
   ) -> (list: List, message: ListMessage) {
      let reposUpdates =
         reposToAddTags
         .compactMap(firstIndex)
         .map { index in
            tags
               .map(\.trimmedWN)
               .uniqued { tag, _ in isValid(tag, at: index) }
               |> { (index: index, toAdd: $0, toExclude: $1) }
         }

      let updatedRepos = reposUpdates.reduce(into: self) {
         $0[$1.index] = $0[$1.index].adding($1.toAdd)
      }

      let reposWithAddedTags =
         reposUpdates
         .filter { !$0.toAdd.isEmpty }
         .map { self[$0.index] }

      let added = Set(reposUpdates.flatMap(\.toAdd)).sorted()
      let excluded = Set(reposUpdates.flatMap(\.toExclude))
         .subtracting(added)
         .sorted()

      return (
         Self(updatedRepos),
         .tagsAdded(added, excluded: excluded, repos: reposWithAddedTags),
      )
   }


   private func isValid(_ tag: String, at index: Index) -> Bool {
      tag.isTagValid && !self[index].tags.contains(tag)
   }
}
