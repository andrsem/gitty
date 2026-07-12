// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Separator tests` {
   @Test(arguments: OutputStyle.allCases, ["&", "-", "||", "<*>", nil])
   func `separator tests`(outputStyle: OutputStyle, symbol: String?) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               components: [.separator(symbol: symbol)],
            ),
            status: status(),
         )

      let expected = (symbol ?? " ", "")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases, ["&", "-", "||", "<*>", nil])
   func `separator remove consecutive`(
      outputStyle: OutputStyle,
      symbol: String?,
   ) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               components: [
                  .separator(symbol: symbol),
                  .separator(symbol: symbol),
                  .separator(symbol: symbol),
               ],
            ),
            status: status(),
         )
      let symbol = symbol ?? " "

      let expected =
         switch outputStyle {
         case .linear: (symbol, "")
         case .columnar: (symbol + symbol + symbol, "")
         }
      expectMatch(expected, statusLine)
   }
}
