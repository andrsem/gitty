// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Detached tests` {
   let symbol = layout().symbols.detached

   @Test(arguments: OutputStyle.allCases)
   func `detached test`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.detached()]),
         status: status(head: "(detached)"),
      )

      let expected = (symbol, "~\(symbol)")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases, [true, false])
   func `sorted by detached`(outputStyle: OutputStyle, isAscending: Bool) {
      let sortComponent = isAscending ? SortComponent.detached : ._detached
      let sortID = isAscending ? "A" : "Z"
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [sortComponent],
            components: [.detached()],
         ),
         status: status(head: "(detached)"),
      )

      let expected = (symbol, "0\(sortID)\(symbol)")
      expectMatch(expected, statusLine)
   }
}
