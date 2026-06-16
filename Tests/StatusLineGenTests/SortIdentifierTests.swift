// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Sort Identifier Tests` {
   @Test(arguments: [true, false])
   func `sort identifier`(aZ: Bool) {
      let order = [SortComponent.modified, .added, ._pull, ._push]
      let added = StatusLineGen.generateSortID(
         for: .added,
         with: "ad",
         isAZ: aZ,
         sortOrder: order
      )
      let modified = StatusLineGen.generateSortID(
         for: .modified,
         with: "mod",
         isAZ: aZ,
         sortOrder: order
      )
      let deleted = StatusLineGen.generateSortID(
         for: .deleted,
         with: "del",
         isAZ: aZ,
         sortOrder: order
      )
      let pull = StatusLineGen.generateSortID(
         for: .pull,
         with: "pl",
         isAZ: aZ,
         sortOrder: order
      )
      let push = StatusLineGen.generateSortID(
         for: .push,
         with: "ps",
         isAZ: aZ,
         sortOrder: order
      )

      let components = [push, added, modified, deleted, pull]
         .shuffled()
         .shuffled()
         .sorted()

      #expect(components == [modified, added, pull, push, deleted])

      #expect(
         components.last == deleted,
         "deleted is sorted last - it is not in the sort order"
      )
   }
}
