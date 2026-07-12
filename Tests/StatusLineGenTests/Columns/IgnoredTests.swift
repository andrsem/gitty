// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Status
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Ignored Tests` {
   let symbol = layout().symbols.ignored

   @Test(arguments: OutputStyle.allCases)
   func `ignored test`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.ignored()]),
         status: status(changedEntries: [.ignored]
         ),
      )

      let expected = (symbol, "~\(symbol)")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases, [true, false])
   func `sorted by ignored`(outputStyle: OutputStyle, isAscending: Bool) {
      let sortComponent = isAscending ? SortComponent.ignored : ._ignored
      let sortID = isAscending ? "A" : "Z"
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [sortComponent],
            components: [.ignored()],
         ),
         status: status(changedEntries: [.ignored]
         ),
      )

      let expected = (symbol, "0\(sortID)\(symbol)")
      expectMatch(expected, statusLine)
   }
}
