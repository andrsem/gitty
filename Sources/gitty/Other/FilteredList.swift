// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import List

extension List {
   func filtered(
      tags: Tags,
      includedPaths: [String],
      excludedPaths: [String],
      fixedString: Bool,
   ) throws -> Self {
      guard !isEmpty else { return self }
      let byPath = try filterReposByPath(
         includedPaths,
         excludedPaths: excludedPaths,
         fixedString: fixedString
      )

      guard !byPath.isEmpty else {
         throw CleanExit.message(FilterListError.noMatchingPath.description)
      }

      let tagsExp = try tags.map { try parseExpression($0, parseValue: \.self) }
      let exp = tagsExp.isEmpty ? nil : Expression.or(tagsExp)
      var nonExisting: [String] = []
      var allTags: [String] = []
      let byTags =
         byPath
         .filter { repo in
            guard let exp else { return true }
            return evaluate(exp) {
               let (_nonExisting, all) = validateTags(in: [$0])
               if !nonExisting.contains(_nonExisting) {
                  nonExisting += _nonExisting
               }
               allTags = all
               return $0 == Tags.reservedTag
                  ? repo.tags.isEmpty
                  : repo.tags.contains($0)
            }
         }

      guard nonExisting.isEmpty else {
         let msg =
            FilterListError.tagsNotExist(nonExisting, allTags: allTags)
            .description
         throw CleanExit.message(msg)
      }

      guard !byTags.isEmpty else {
         throw CleanExit.message(FilterListError.noUntaggedRepos.description)
      }

      return byTags
   }
}



enum FilterListError: Error, Equatable {
   case noMatchingPath
   case noUntaggedRepos
   case tagsNotExist(Tags, allTags: Tags)
}



extension FilterListError: CustomStringConvertible {
   var description: String {
      switch self {
      case .noMatchingPath: "No repos found for the matching path."
      case .noUntaggedRepos: "No untagged repos."
      case let .tagsNotExist(nonExistingTags, allTags: allTags):
         List.tagsDescription(with: nonExistingTags, allTags: allTags)
      }
   }
}
