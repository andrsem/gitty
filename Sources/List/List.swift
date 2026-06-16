// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import Algorithms
import Foundation
import SW40
import Shared

package typealias List = [Repo]

extension List {
   /// Adds `Repo`s to the list.
   ///
   /// - Note: `Repo`s are considered equal when:
   ///   - same path name, regardless of tags
   ///   - path with or without a trailing slash `/`
   ///   - the tilde `~` is expanded or not
   package func adding(_ newRepos: Self) -> (list: Self, message: ListMessage) {
      newRepos
         .filter { repo in allSatisfy { repo != $0 } }
         .uniqued()
         |> Array.init
         |> { (Self(self + $0), .added($0)) }
   }


   /// Removing `Repo`s from the list.
   package func removing(
      _ path: String,
      fixedString: Bool = false,
   ) throws(InvalidRegex) -> (list: Self, message: ListMessage) {
      let (kept, removed) =
         try removedAll { (repo) throws(InvalidRegex) in
            try repo.matchesPattern(path, fixedString: fixedString)
         }

      return (Self(kept), .removed(removed))
   }


   package func filterReposByTags(
      _ tags: Tags,
      excluding: Bool = false,
   ) -> Self {
      guard !tags.isEmpty else { return self }
      return
         filter {
            let notTagged = tags.contains(Tags.reservedTag) && $0.tags.isEmpty
            let include = notTagged || $0.containsAny(tags)
            return excluding ? !include : include
         }
         |> Self.init
   }


   package func filterReposByPath(
      _ paths: [String],
      excludedPaths: [String] = [],
      fixedString: Bool = false,
   ) throws(InvalidRegex) -> Self {
      guard !paths.isEmpty || !excludedPaths.isEmpty else { return self }

      func matches(_ repo: Repo, in paths: [String]) throws -> Bool {
         try paths.contains {
            try repo.matchesPattern($0, fixedString: fixedString)
         }
      }

      return
         try Result {
            try filter { repo in
               let matchesInclude = try matches(repo, in: paths)
               let matchesExclude = try matches(repo, in: excludedPaths)
               return paths.isEmpty
                  ? !matchesExclude
                  : matchesInclude && !matchesExclude
            }
         }
         .mapError(InvalidRegex.init)
         .get()
   }


   package func validateTags(
      in tags: Tags,
   ) -> (nonExisting: Tags, allTags: Tags) {
      let allTags = flatMap(\.tags) |> Set.init
      let tags = Set(tags).filter { $0 != Tags.reservedTag }
      let nonExistingTags = tags.subtracting(allTags).sorted()

      let sortedAllTags = allTags.sorted()
      return allTags.isSuperset(of: tags)
         ? ([], sortedAllTags)
         : (nonExistingTags, sortedAllTags)
   }


   /// Removing duplicate and invalid `Repo`s, as well as duplicate tags.
   ///
   /// The first unique `Repo` remains in the list.
   ///
   /// - Note: `Repo`s are considered equal when:
   ///   - same path name, regardless of tags
   ///   - path with or without a trailing slash `/`
   ///   - the tilde `~` is expanded or not
   func cleaning(
      isPathValid: (_ path: String) -> Bool,
   ) -> Self {
      uniqued()
         .reduce(into: Self()) {
            let path = $1.url.path(percentEncoded: false)
            guard isPathValid(path) else { return }
            let cleanRepo = $1.cleaningTags().repo
            $0.append(cleanRepo)
         }
   }
}
