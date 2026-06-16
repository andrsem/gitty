// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import Layout

@Suite(.tags(.layout))
struct `Text Color Tests` {
   typealias Pair = (raw: String, color: TextColor)

   @Test(
      arguments: [Pair]([
         ("black", .black),
         ("red", .red),
         ("green", .green),
         ("yellow", .yellow),
         ("blue", .blue),
         ("magenta", .magenta),
         ("cyan", .cyan),
         ("white", .white),
         ("brightBlack", .brightBlack),
         ("brightRed", .brightRed),
         ("brightGreen", .brightGreen),
         ("brightYellow", .brightYellow),
         ("brightBlue", .brightBlue),
         ("brightMagenta", .brightMagenta),
         ("brightCyan", .brightCyan),
         ("brightWhite", .brightWhite),
         ("rgb 255 255 255", .rgb(255, 255, 255)),
         ("hsb 300 0.2 0.99", .hsb(300, 0.2, 0.99)),
         ("ext10", .ext(10)),
         ("ext 10", .ext(10)),
         ("ext  10  ", .ext(10)),
         ("hex #FFF", .hex("#FFF")),
         ("hex FFF", .hex("FFF")),
         ("hex #FFFFFF", .hex("#FFFFFF")),
         ("hex FFFFFF", .hex("FFFFFF")),
      ])
   )
   func `initialize from valid rawValue`(pair: Pair) {
      let color = TextColor(rawValue: pair.raw)
      #expect(color == pair.color)
   }


   @Test(
      arguments: [
         "abc",
         "ext",
         "ext -10",
         "ext 256",
         "hex",
         "hex, #FFFF",
         "hex, #F F F",
         "hex FFFFFFFF",
         "hsb",
         "hsb 400 0 0",
         "hsb 0 3 0",
         "hsb 0 0 -10",
         "rgb",
         "rgb -100 0 0",
         "rgb 0 330 0",
         "rgb 0 0 990",
      ]
   )
   func `initialize from invalid rawValue`(raw: String) {
      let color = TextColor(rawValue: raw)
      #expect(color == nil)
   }
}
