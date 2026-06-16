// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import Status

@Suite(.tags(.status))
struct `Sub tests` {
   @Test(arguments: ["", " ", "N", ".N..", "Cat", "N."])
   func `invalid submodule raw`(raw: String) {
      #expect(Sub(from: raw) == nil)
   }


   @Test
   func `submodule status`() {
      #expect(Sub(from: "N...") == .notSubmodule)
      #expect(
         Sub(from: "S...")
            == .isSubmodule(
               isCommitChanged: false,
               hasTrackedChanges: false,
               hasUntrackedChanges: false
            )
      )
      #expect(
         Sub(from: "SC..")
            == .isSubmodule(
               isCommitChanged: true,
               hasTrackedChanges: false,
               hasUntrackedChanges: false
            )
      )
      #expect(
         Sub(from: "SCMU")
            == .isSubmodule(
               isCommitChanged: true,
               hasTrackedChanges: true,
               hasUntrackedChanges: true
            )
      )
   }
}
