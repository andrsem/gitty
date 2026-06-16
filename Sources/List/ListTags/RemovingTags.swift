// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT


import SW40
import Shared

extension List {
   /// After removing, tags are sorted A-Z.
   package func removingTags(
      _ tags: Tags,
      includedPaths: [String],
      excludedPaths: [String] = [],
   ) throws -> (list: Self, message: ListMessage) {
      try tagsAction(includedPaths, excludedPaths: excludedPaths) {
         _removingTags(tags, from: $0)
      }
   }


   private func _removingTags(
      _ tags: Tags,
      from list: List,
   ) -> (list: List, message: ListMessage) {
      let reposUpdates =
         list
         .compactMap { firstIndex(of: $0) }
         .map { index in
            tags
               .map(\.trimmedWN)
               .uniqued { tag, _ in self[index].tags.contains(tag) }
               |> { (index: index, toRemove: $0, toExclude: $1) }
         }

      let updatedRepos = reposUpdates.reduce(into: self) {
         $0[$1.index] = $0[$1.index].removing($1.toRemove)
      }

      let reposWithRemovedTags =
         reposUpdates
         .filter { !$0.toRemove.isEmpty }
         .map { self[$0.index] }

      let removedTags = Set(reposUpdates.flatMap(\.toRemove)).sorted()
      let excluded = Set(reposUpdates.flatMap(\.toExclude))
         .subtracting(removedTags)
         .sorted()

      return (
         Self(updatedRepos),
         .tagsRemoved(
            removedTags,
            excluded: excluded,
            repos: reposWithRemovedTags
         )
      )
   }
}
