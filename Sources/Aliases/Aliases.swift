// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Foundation
import SW40
import Shared

package typealias Aliases = [Alias]


package struct Alias {
   package init(
      _ name: String,
      args: [String],
      details: String? = nil,
      flags: [Flag] = [],
      status: [StatusFilter] = [],
      delay: Int = .zero,
      sort: OutputSort = .unsorted,
   ) throws(AliasError) {
      let name = name.trimmedWN
      guard !name.isEmpty, !name.contains(" ") else {
         throw .invalidName
      }

      guard !args.isEmpty else { throw .invalidCommand }

      self.name = name
      self.args = args
      self.details = details ?? ""
      self.flags = flags.sorted()
      self.status = status
      self.delay = max(.zero, delay)
      self.sort = sort
   }


   package let name: String
   package let args: [String]
   package let details: String
   package let flags: [Flag]
   package let status: [StatusFilter]
   package let delay: Int
   package let sort: OutputSort


   func cleaned() throws -> Self {
      try (name, args, details, flags, status, delay, sort) |> Self.init
   }
}



package enum AliasError: Error, CustomStringConvertible {
   case invalidName
   case invalidCommand


   package var description: String {
      switch self {
      case .invalidName: "Alias name cannot be empty or contain spaces."
      case .invalidCommand: "Alias command arguments cannot be empty."
      }
   }
}



package enum OutputSort: String, Decodable, CaseIterable, Sendable {
   case az, za, unsorted
}



extension Alias {
   package enum StatusFilter: String, CaseIterable, Decodable, Sendable {
      case added
      case clean
      case copied
      case deleted
      case detached
      case ignored
      case initialCommit = "initial-commit"
      case locked
      case modified
      case needsPull = "needs-pull"
      case needsPush = "needs-push"
      case needsUpstream = "needs-upstream"
      case renamed
      case submodule
      case subCommitChange = "sub-commit-change"
      case subModified = "sub-modified"
      case subUntracked = "sub-untracked"
      case typeChange = "type-change"
      case unmerged
      case untracked
   }


   package enum Flag: String, CaseIterable, Decodable, Sendable {
      case compact, parallel, quiet
   }
}



extension Alias.StatusFilter: Comparable {
   package static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.rawValue < rhs.rawValue
   }
}



extension Alias.Flag: Comparable {
   package static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.rawValue < rhs.rawValue
   }
}


extension Alias: Decodable {}
extension Alias: Hashable {}
extension Alias: Sendable {}



extension Alias: Comparable {
   package static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.name < rhs.name
   }
}
