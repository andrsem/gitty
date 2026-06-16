// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import TTS
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Stashes tests` {
   @Test(arguments: OutputStyle.allCases)
   func `stashes zero`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.stashes()]),
            status: status()
         )

      let expected =
         switch outputStyle {
         case .linear: ("", "")
         case .columnar: ("   ", "~#")
         }

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `stashes one`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.stashes()]),
            status: status(stashCount: 1)
         )

      let expected =
         switch outputStyle {
         case .linear: ("#1", "~#")
         case .columnar: ("#1 ", "~#")
         }

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `stashes exceeding max count`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, maxCount: 9, components: [.stashes()]),
            status: status(stashCount: 10)
         )

      let expected = ("#9", "~#")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `stashes hide count`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               components: [.stashes(hideCount: true)]
            ),
            status: status(stashCount: 10)
         )

      let expected = ("#", "~#")
      expectMatch(expected, statusLine)
   }
}
