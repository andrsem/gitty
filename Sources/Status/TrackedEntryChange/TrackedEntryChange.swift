// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import SW40

package enum TrackedEntryChange {
   /// orcu change
   ///
   /// orcu stands for change:
   ///  - o - ordinary
   ///  - r - renamed
   ///  - c - copied
   ///  - u - unmerged
   case orcuChange(xy: XY, sub: Sub)
   case ignored
   case untracked


   init?(from line: some StringProtocol) {
      switch String(line.prefix(1)) {
      case LineID.ordinary, LineID.unmerged, LineID.renamedOrCopied:
         let components = line.split(separator: " ", maxSplits: 3)
         guard
            let xy = XY(from: components[safe: 1]),
            let sub = Sub(from: components[safe: 2])
         else { return nil }
         self = .orcuChange(xy: xy, sub: sub)

      case LineID.ignored: self = .ignored
      case LineID.untracked: self = .untracked
      default: return nil
      }
   }
}


extension TrackedEntryChange: Hashable {}
extension TrackedEntryChange: Sendable {}
