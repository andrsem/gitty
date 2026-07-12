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
struct `Untracked tests` {
   let symbol = layout().symbols.untracked

   @Test(arguments: OutputStyle.allCases)
   func `untracked tests`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.untracked()]),
            status: status(),
         )

      let expected =
         switch outputStyle {
         case .linear: ("", "")
         case .columnar: (" ", "~\(symbol)")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `untracked change test`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.untracked()]),
         status: status(changedEntries: [.untracked]
         ),
      )

      let expected = (symbol, "~\(symbol)")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases, [true, false])
   func `sorted by untracked`(outputStyle: OutputStyle, isAscending: Bool) {
      let sortComponent = isAscending ? SortComponent.untracked : ._untracked
      let sortID = isAscending ? "A" : "Z"
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [sortComponent],
            components: [.untracked()],
         ),
         status: status(changedEntries: [.untracked]
         ),
      )

      let expected = (symbol, "0\(sortID)\(symbol)")
      expectMatch(expected, statusLine)
   }
}
