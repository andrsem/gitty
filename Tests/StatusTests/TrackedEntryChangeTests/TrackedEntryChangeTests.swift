// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Testing

@testable import Status

@Suite
struct `Tracked entry change tests` {
   @Test
   func `ignored changes`() {
      let change = TrackedEntryChange(from: "! some cool file.txt")
      #expect(change == .ignored)
   }


   @Test
   func `untracked changes`() {
      let change = TrackedEntryChange(from: "? someFile.txt")
      #expect(change == .untracked)
   }


   @Test
   func `renamed or copied change`() {
      let change = TrackedEntryChange(
         from:
            "2 R. N... 100644 100644 100644 86ae72dc46d170b8c05588643b3c9a605d1ea1de 86ae72dc46d170b8c05588643b3c9a605d1ea1de R100 unusual file path renamed.txt\tunusual file path.txt"
      )
      let expected = TrackedEntryChange.orcuChange(
         xy: XY(index: .renamed, workingTree: .unmodified),
         sub: .notSubmodule,
      )
      expectMatch(expected, change)
   }


   @Test
   func `ordinary change`() {
      let change = TrackedEntryChange(
         from:
            "1 AM N... 100644 100644 100644 b9d020b68ccdd71b3eaa3f72cf552fa189f1e36b b9d020b68ccdd71b3eaa3f72cf552fa189f1e36b fileName with spaces.txt"
      )
      let expected =
         TrackedEntryChange.orcuChange(
            xy: XY(index: .added, workingTree: .modified),
            sub: .notSubmodule,
         )
      expectMatch(expected, change)
   }


   @Test
   func `unmerged change`() {
      let change = TrackedEntryChange(
         from:
            "u UU N... 100644 100644 100644 100644 3fad3df99be4c64dfd4a9aa6ba527a5f0c1251b0 b9d020b68ccdd71b3eaa3f72cf552fa189f1e36b cad4b8504d9af4f144a2e6e724c061bc2b020c88 filename with spaces.txt"
      )


      let expected = TrackedEntryChange.orcuChange(
         xy: XY(index: .unmerged, workingTree: .unmerged),
         sub: Sub.notSubmodule,
      )
      expectMatch(expected, change)
   }
}
