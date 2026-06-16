// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Status
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `InitialCommit tests` {
   let symbol = layout().symbols.initialCommit

   @Test(arguments: OutputStyle.allCases)
   func `no commits test`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.initialCommit()]
         ),
         status: status(oid: "(initial)")
      )

      let expected = (symbol, "~\(symbol)")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases, [true, false])
   func `sorted by noCommits`(outputStyle: OutputStyle, isAscending: Bool) {
      let sortComponent =
         isAscending ? SortComponent.initialCommit : ._initialCommit
      let sortID = isAscending ? "A" : "Z"
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [sortComponent],
            components: [.initialCommit()]
         ),
         status: status(oid: "(initial)")
      )

      let expected = (symbol, "0\(sortID)\(symbol)")
      expectMatch(expected, statusLine)
   }
}
