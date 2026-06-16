// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Status
import TTS
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Submodules tests` {
   @Test(arguments: OutputStyle.allCases)
   func `submodules without components`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.submodules()]),
            status: status()
         )

      let expected =
         switch outputStyle {
         case .linear: ("", "")
         case .columnar: ("  ", "~sub:")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `submodules without components with sub changes`(
      outputStyle: OutputStyle
   ) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.submodules()]),
            status: status(
               changedEntries: [
                  .orcuChange(
                     xy: .init(index: .unmodified, workingTree: .unmodified),
                     sub: .isSubmodule(
                        isCommitChanged: true,
                        hasTrackedChanges: false,
                        hasUntrackedChanges: true
                     )
                  )
               ]
            )
         )

      let expected = ("<>", "~sub:")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `submodules with components`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               components: [
                  .submodules(
                     components: [
                        .commit(),
                        .modified(),
                        .untracked(),
                     ]
                  )
               ]
            ),
            status: status()
         )

      let expected =
         switch outputStyle {
         case .linear: ("", "")
         case .columnar: ("     ", "~sub:")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `submodules with components and changes`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               components: [
                  .submodules(
                     components: [
                        .commit(),
                        .modified(),
                        .untracked(),
                     ]
                  )
               ]
            ),
            status: status(
               changedEntries: [
                  .orcuChange(
                     xy: .init(index: .unmodified, workingTree: .unmodified),
                     sub: .isSubmodule(
                        isCommitChanged: true,
                        hasTrackedChanges: false,
                        hasUntrackedChanges: true
                     )
                  )
               ]
            )
         )

      let expected =
         switch outputStyle {
         case .linear: ("<C?>", "~sub:")
         case .columnar: ("<C ?>", "~sub:")
         }

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `submodules with components and changes 2`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               components: [
                  .submodules(
                     components: [
                        .commit(),
                        .modified(),
                        .untracked(),
                     ]
                  )
               ]
            ),
            status: status(
               changedEntries: [
                  .orcuChange(
                     xy: .init(index: .unmodified, workingTree: .unmodified),
                     sub: .isSubmodule(
                        isCommitChanged: false,
                        hasTrackedChanges: true,
                        hasUntrackedChanges: false
                     )
                  )
               ]
            )
         )

      let expected =
         switch outputStyle {
         case .linear: ("<M>", "~sub:")
         case .columnar: ("< M >", "~sub:")
         }

      expectMatch(expected, statusLine)
   }
}
