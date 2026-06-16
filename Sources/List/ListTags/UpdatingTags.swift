// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import SW40
import Shared

extension List {
   /// After updating, tags are sorted A-Z.
   package func updatingTags(
      _ tags: Tags,
      includedPaths: [String],
      excludedPaths: [String] = [],
   ) throws -> (list: Self, message: ListMessage) {
      try tagsAction(includedPaths, excludedPaths: excludedPaths) {
         _updatingTags(tags, from: $0)
      }
   }


   private func _updatingTags(
      _ tags: Tags,
      from repos: [Repo],
   ) -> (list: List, message: ListMessage) {
      guard
         tags.count == 2,
         let old = tags[safe: 0]?.trimmedWN,
         let new = tags[safe: 1]?.trimmedWN
      else {
         return (self, .noOldNewForUpdate)
      }

      guard new.isTagValid, old.isTagValid else {
         return (self, .tagsNotUpdated(old: old, new: new))
      }

      let indexes = repos.compactMap(firstIndex)

      let updatedRepos = indexes.reduce(into: self) {
         $0[$1] = $0[$1].updating(old, with: new)
      }

      let indexesWithUpdatedTags =
         indexes.filter { self[$0].tags.contains(old) }

      let reposWithUpdatedTags = indexesWithUpdatedTags.map { self[$0] }
      let areTagsUpdated = !indexesWithUpdatedTags.isEmpty

      let message: ListMessage =
         areTagsUpdated
         ? .tagsUpdated(old: old, new: new, repos: reposWithUpdatedTags)
         : .tagsNotUpdated(old: old, new: new)

      return (Self(updatedRepos), message)
   }


   func tagsAction(
      _ includedPaths: [String],
      excludedPaths: [String],
      action: ([Repo]) -> (list: Self, message: ListMessage),
   ) throws -> (list: Self, message: ListMessage) {
      try filterReposByPath(includedPaths, excludedPaths: excludedPaths)
         |> { $0.isEmpty ? (self, .noReposWithPath) : action($0) }
   }
}
