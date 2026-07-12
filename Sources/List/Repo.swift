// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package import Foundation
import SW40
import Shared

package struct Repo {
   package let path: String
   package let tags: Tags

   package init(_ path: String, _ tags: Tags = []) {
      let normalizedPath =
         URL(filePath: path.trimmedWN, directoryHint: .isDirectory)
         .standardizedFileURL
         .path(percentEncoded: false)

      self.path = normalizedPath
      self.tags = tags
   }


   package var url: URL {
      URL(
         filePath: path.removingPercentEncoding ?? "",
         directoryHint: .isDirectory,
      )
   }


   func adding(_ tags: Tags) -> Self {
      Set(tags)
         .subtracting(self.tags)
         .filter(\.isTagValid)
         |> { (self.tags + $0).sorted() }
         |> { Self(path, $0) }
   }


   func removing(_ tags: Tags) -> Self {
      self.tags
         .filter { !tags.contains($0) && $0.isTagValid }
         |> { Self(path, $0.sorted()) }
   }


   func updating(_ old: String, with new: String) -> Self {
      let new = new.trimmedWN

      guard
         new.isTagValid,
         let index = tags.firstIndex(of: old)
      else { return self }

      var updated = tags
      updated[index] = new
      return Self(path, updated.uniqueSorted())
   }


   func cleaningTags() -> (repo: Self, removedTags: Tags) {
      tags
         .map(\.trimmedWN)
         .uniqued { !$1.contains($0) && $0.isTagValid }
         |> { ($0.sorted(), $1.sorted()) }
         |> { (Self(path, $0), $1) }
   }


   func matchesPattern(
      _ pattern: String,
      fixedString: Bool,
   ) throws(InvalidRegex) -> Bool {
      let expanded = NSString(string: pattern).expandingTildeInPath
      return fixedString
         ? path.trimmingSuffix("/") == expanded.trimmingSuffix("/")
         : try Result { path.contains(try Regex(expanded)) }
            .mapError(InvalidRegex.init)
            .get()
   }


   func containsAny(_ tags: Tags) -> Bool {
      self.tags.contains(where: tags.contains)
   }
}



package struct InvalidRegex: Error, Equatable, CustomStringConvertible {
   let message: String
   package var description: String { "Invalid path regex: " + message }
}


extension InvalidRegex {
   init(_ error: any Error) {
      message = String(describing: error)
   }
}



extension Tags {
   fileprivate func uniqueSorted() -> Tags { Set(self).sorted() }
}


extension Repo: Codable {}
extension Repo: Sendable {}
extension Repo: Hashable {
   /// Only path is compared.
   package static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.path == rhs.path
   }


   /// Only path is hashed.
   package func hash(into hasher: inout Hasher) {
      hasher.combine(path)
   }
}

extension Repo: Comparable {
   /// Only path is compared.
   package static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.path < rhs.path
   }
}
