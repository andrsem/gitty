// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Status
import Testing

@Suite(.tags(.status))
struct `Status Ext Tests` {
   @Test
   func `change not found`() {
      let set: Set = [ordinaryAD]
      #expect(set.containsChange(.modified) == false)
      #expect(set.containsChange(.unmerged) == false)
   }


   @Test(arguments: XY.Change.allCases)
   func `all possible XY changes found`(change: XY.Change) {
      #expect(allChanges.containsChange(change) == true)
   }


   @Test(arguments: XY.Change.allCases)
   func `ignored and untracked doesn't have any XY changes`(change: XY.Change) {
      let set: Set = [ignored, untracked]
      #expect(set.containsChange(change) == false)
   }


   @Test
   func `contains ignored and untracked`() {
      #expect(allChanges.containsIgnored() == true)
      #expect(allChanges.containsUntracked() == true)

      let set: Set = [ordinaryAD]
      #expect(set.containsIgnored() == false)
      #expect(set.containsUntracked() == false)
   }


   @Test
   func `contains submodules`() {
      let set: Set = [ordinaryADSub, ordinaryAD, renamedOrCopiedTCSub]
      #expect(set.containsSubmodule())
   }


   @Test
   func `does not contain submodules`() {
      let set: Set = [untracked, ordinaryAD]
      #expect(!set.containsSubmodule())
   }


   @Test
   func `not a submodule`() {
      let set: Set = [ordinaryAD]
      expectMatch((false, false, false), set.hasSubmoduleChanges())
   }


   @Test
   func `submodule without changes`() {
      let set: Set = [ordinaryADSubNoChange]
      expectMatch((false, false, false), set.hasSubmoduleChanges())
   }

   @Test
   func `untracked and ignored don't have sub changes`() {
      let set: Set = [untracked, ignored]
      expectMatch((false, false, false), set.hasSubmoduleChanges())
   }


   @Test
   func `with submodule changes`() {
      let set: Set = [
         unmergedMRSub,
         ordinaryADSub,
         renamedOrCopiedTCSub,
         ordinaryADSubNoChange,
      ]
      expectMatch((true, true, true), set.hasSubmoduleChanges())
   }


   var allChanges: Set<TrackedEntryChange> {
      [
         ignored,
         untracked,
         ordinaryAD,
         unmergedMRSub,
         renamedOrCopiedTCSub,
         renamedOrCopiedUU,
      ]
   }

   static let ordinary = TrackedEntryChange.orcuChange(
      xy: .init(index: .added, workingTree: .deleted),
      sub: .notSubmodule
   )
   static let ordinarySub = TrackedEntryChange.orcuChange(
      xy: .init(index: .added, workingTree: .deleted),
      sub: .isSubmodule(
         isCommitChanged: true,
         hasTrackedChanges: false,
         hasUntrackedChanges: false
      )
   )
   static let ordinarySubNoChange = TrackedEntryChange.orcuChange(
      xy: .init(index: .added, workingTree: .deleted),
      sub: .isSubmodule(
         isCommitChanged: false,
         hasTrackedChanges: false,
         hasUntrackedChanges: false
      )
   )

   static let unmerged = TrackedEntryChange.orcuChange(
      xy: .init(index: .modified, workingTree: .renamed),
      sub: .isSubmodule(
         isCommitChanged: false,
         hasTrackedChanges: true,
         hasUntrackedChanges: false
      ),
   )
   static let renamed = TrackedEntryChange.orcuChange(
      xy: .init(index: .typeChange, workingTree: .copied),
      sub: .isSubmodule(
         isCommitChanged: false,
         hasTrackedChanges: false,
         hasUntrackedChanges: true
      ),
   )
   static let renamed2 = TrackedEntryChange.orcuChange(
      xy: .init(index: .unmodified, workingTree: .unmerged),
      sub: .notSubmodule
   )

   let ignored = TrackedEntryChange.ignored
   let untracked = TrackedEntryChange.untracked
   let ordinaryAD = ordinary
   let ordinaryADSub = ordinarySub
   let ordinaryADSubNoChange = ordinarySubNoChange
   let unmergedMRSub = unmerged
   let renamedOrCopiedTCSub = renamed
   let renamedOrCopiedUU = renamed2
}
