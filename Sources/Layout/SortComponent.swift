// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Shared

package typealias CustomSortID = String

package enum SortComponent {
   case custom(CustomSortID?)
   case head
   case oid
   case repo
   case upstream

   case added, _added
   case copied, _copied
   case clean, _clean
   case deleted, _deleted
   case detached, _detached
   case ignored, _ignored
   case initialCommit, _initialCommit
   case locked, _locked
   case modified, _modified
   case noUpstream, _noUpstream
   case pull, _pull
   case push, _push
   case renamed, _renamed
   case stashes, _stashes
   case submodules, _submodules
   case typeChange, _typeChange
   case unmerged, _unmerged
   case untracked, _untracked
}


extension SortComponent: Sendable {}
extension SortComponent: Decodable {}
extension SortComponent: Equatable {}
extension SortComponent: RawRepresentable {
   package var rawValue: String { String(describing: self) }

   package init?(rawValue: String) {
      let component: Self? =
         switch rawValue {
         case "head": .head
         case "oid": .oid
         case "repo": .repo
         case "upstream": .upstream

         case "added": .added
         case "!added": ._added
         case "clean": .clean
         case "!clean": ._clean
         case "copied": .copied
         case "!copied": ._copied
         case "deleted": .deleted
         case "!deleted": ._deleted
         case "detached": .detached
         case "!detached": ._detached
         case "ignored": .ignored
         case "!ignored": ._ignored
         case "initialCommit": .initialCommit
         case "!initialCommit": ._initialCommit
         case "locked": .locked
         case "!locked": ._locked
         case "modified": .modified
         case "!modified": ._modified
         case "noUpstream": .noUpstream
         case "!noUpstream": ._noUpstream
         case "pull": .pull
         case "!pull": ._pull
         case "push": .push
         case "!push": ._push
         case "renamed": .renamed
         case "!renamed": ._renamed
         case "stashes": .stashes
         case "!stashes": ._stashes
         case "submodules": .submodules
         case "!submodules": ._submodules
         case "typeChange": .typeChange
         case "!typeChange": ._typeChange
         case "unmerged": .unmerged
         case "!unmerged": ._unmerged
         case "untracked": .untracked
         case "!untracked": ._untracked

         case let custom: Self.parse(custom)
         }

      guard let component else { return nil }
      self = component
   }


   private static func parse(_ custom: String) -> SortComponent? {
      let customPrefix = "custom:"
      guard custom.hasPrefix(customPrefix) else { return nil }

      let trimmed = custom.trimmingPrefix(customPrefix).trimmedWN
      guard !trimmed.isEmpty else { return nil }

      return .custom(trimmed)
   }
}
