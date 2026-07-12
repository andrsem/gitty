// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import SW40
import TTS
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Clean all components tests` {
   @Test
   func `linear clean status line with all components`() {
      let line = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: layout(.linear, components: allComponents),
         status: cleanStatus,
      )
      .line

      let expected = "fbc7d6amain✓myURL origin/main"
      expectMatch(expected, line)
   }


   @Test
   func `columnar clean status line with all components`() {
      let line = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: layout(.columnar, components: allComponents),
         status: cleanStatus,
      )
      .line

      let expected =
         "                           "
         + "fbc7d6a"
         + "main"
         + "✓"
         + "myURL"
         + " "
         + "origin/main"

      expectMatch(expected, line)
   }
}
