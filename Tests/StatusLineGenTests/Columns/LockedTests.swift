// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Locked tests` {
   let symbol = layout().symbols.locked

   @Test(arguments: OutputStyle.allCases)
   func `locked test`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.locked()]),
         status: status(isLocked: true)
      )

      let expected = (symbol, "~\(symbol)")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases, [true, false])
   func `sorted by locked`(outputStyle: OutputStyle, isAscending: Bool) {
      let sortComponent = isAscending ? SortComponent.locked : ._locked
      let sortID = isAscending ? "A" : "Z"
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [sortComponent],
            components: [.locked()]
         ),
         status: status(isLocked: true)
      )

      let expected = (symbol, "0\(sortID)\(symbol)")
      expectMatch(expected, statusLine)
   }
}
