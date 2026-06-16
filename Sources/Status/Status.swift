// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

package import Foundation
import SW40
import Shared

package struct Status {
   package init(
      oid: String,
      head: String,
      upstream: String,
      pullCount: Int,
      pushCount: Int,
      stashCount: Int,
      isLocked: Bool,
      changedEntries: Set<TrackedEntryChange>
   ) {
      self.oid = oid
      self.head = head
      self.upstream = upstream
      self.pullCount = pullCount
      self.pushCount = pushCount
      self.stashCount = stashCount
      self.isLocked = isLocked
      self.changedEntries = changedEntries
   }

   package let oid: String
   package let head: String
   package let upstream: String
   package let pullCount: Int
   package let pushCount: Int
   package let stashCount: Int
   package let isLocked: Bool
   package let changedEntries: Set<TrackedEntryChange>

   package var needsPush: Bool { pushCount > .zero }
   package var needsPull: Bool { pullCount > .zero }
   package var needsUpstream: Bool { upstream.isEmpty }
   package var isClean: Bool { changedEntries.isEmpty }
   package var isDetached: Bool { head == "(detached)" }
   package var isInitialCommit: Bool { oid == "(initial)" }


   package static func parse(
      at repoDir: URL,
      ignored: Bool,
      lockFileExists: (String) -> Bool,
      run: ([String], URL) async -> (output: String, error: String),
   ) async throws(StatusError) -> (status: Self, error: String, raw: String) {
      let args = gitStatusArgs(ignored: ignored)
      let (raw, error) = await run(args, repoDir)
      let components =
         raw
         .split(whereSeparator: \.isNewline)
         .reduce(into: StatusComponents(), extractingComponents)

      guard !components.oid.isEmpty, !components.head.isEmpty else {
         throw .invalidRaw(error)
      }

      let status = Self(
         oid: components.oid,
         head: components.head,
         upstream: components.upstream,
         pullCount: components.pullCount,
         pushCount: components.pushCount,
         stashCount: components.stashCount,
         isLocked: isRepoLocked(repoDir, lockFileExists),
         changedEntries: components.changedEntries
      )

      return (status, error, raw)
   }


   private static func gitStatusArgs(ignored: Bool) -> [String] {
      [
         "--no-optional-locks",
         "status",
         "--branch",
         "--show-stash",
         "--porcelain=v2",
         "--ignored=\(ignored ? "traditional" : "no")",
      ]
   }


   private struct StatusComponents {
      var oid: String = ""
      var head: String = ""
      var upstream: String = ""
      var pullCount: Int = .zero
      var pushCount: Int = .zero
      var stashCount: Int = .zero
      var changedEntries: Set<TrackedEntryChange> = []
   }


   private static func extractingComponents(
      _ components: inout StatusComponents,
      from line: Substring,
   ) {
      switch line.prefix(1) {
      case LineID.ordinary,
         LineID.unmerged,
         LineID.renamedOrCopied,
         LineID.ignored,
         LineID.untracked:
         if let change = TrackedEntryChange(from: line) {
            components.changedEntries.insert(change)
         }

      case LineID.branch:
         if let oid = extractBranchStatus("# branch.oid", from: line) {
            components.oid = oid
         }

         if let head = extractBranchStatus("# branch.head", from: line) {
            components.head = head
         }

         if let upstream = extractBranchStatus("# branch.upstream", from: line)
         {
            components.upstream = upstream
         }

         if let stashStr = extractBranchStatus("# stash", from: line),
            let stash = Int(stashStr)
         {
            components.stashCount = stash
         }

         if let (push, pull) = extractPushPullCount(from: line) {
            components.pushCount = push
            components.pullCount = pull
         }

      default: return
      }
   }


   private static func isRepoLocked(
      _ repoDir: URL,
      _ lockFileExists: (String) -> Bool,
   ) -> Bool {
      repoDir
         .appending(component: ".git/index.lock")
         .path()
         |> lockFileExists
   }


   private static func extractPushPullCount(
      from line: some StringProtocol
   ) -> (pushCount: Int, pullCount: Int)? {
      extractBranchStatus("# branch.ab", from: line)?
         .split(separator: " ")
         .reduce(into: (pushCount: .zero, pullCount: .zero)) {
            guard let count = Int($1.dropFirst()) else { return }
            if $1.hasPrefix("+") { $0.pushCount = count }
            if $1.hasPrefix("-") { $0.pullCount = count }
         }
   }


   private static func extractBranchStatus(
      _ prefix: String,
      from line: some StringProtocol,
   ) -> String? {
      guard line.hasPrefix(prefix) else { return nil }
      return line.trimmingPrefix(prefix).trimmedWN
   }
}



extension Status: Equatable {}
extension Status: Sendable {}


extension Set<TrackedEntryChange> {
   package func containsChange(_ change: XY.Change) -> Bool {
      contains {
         switch $0 {
         case let .orcuChange(xy, _): xy.contains(change)
         default: false
         }
      }
   }


   package func hasSubmoduleChanges() -> (
      commit: Bool, modified: Bool, untracked: Bool
   ) {
      var result = (commit: false, modified: false, untracked: false)
      for entry in self where entry.hasSubmodule {
         guard result != (true, true, true) else { break }

         let (hasCommit, isModified, isUntracked) =
            switch entry {
            case let .orcuChange(_, sub): sub.changes
            default: (false, false, false)
            }

         if hasCommit { result.commit = true }
         if isModified { result.modified = true }
         if isUntracked { result.untracked = true }
      }

      return result
   }


   package func containsSubmodule() -> Bool { contains(where: \.hasSubmodule) }


   package func containsIgnored() -> Bool {
      contains { if case .ignored = $0 { true } else { false } }
   }


   package func containsUntracked() -> Bool {
      contains { if case .untracked = $0 { true } else { false } }
   }
}



extension TrackedEntryChange {
   fileprivate var hasSubmodule: Bool {
      switch self {
      case let .orcuChange(_, sub): sub.isSubmodule
      default: false
      }
   }
}



extension Sub {
   fileprivate var isSubmodule: Bool {
      if case .isSubmodule = self { true } else { false }
   }


   fileprivate var changes: (Bool, Bool, Bool) {
      guard case let .isSubmodule(c, m, u) = self else {
         return (false, false, false)
      }
      return (c, m, u)
   }
}
