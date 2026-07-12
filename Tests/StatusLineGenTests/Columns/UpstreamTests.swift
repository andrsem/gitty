// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import SW40
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Upstream tests` {
   @Test(arguments: OutputStyle.allCases)
   func `upstream no width specified`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.upstream()]),
            status: status(),
         )

      let expected = ("origin/main", "~upst:origin/main")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `upstream expanded to width`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.upstream(width: 15)]),
            status: status(),
         )

      let expected =
         switch outputStyle {
         case .linear: ("origin/main", "~upst:origin/main")
         case .columnar: ("origin/main    ", "~upst:origin/main")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `upstream truncated to width truncationMode: nil - global`(
      outputStyle: OutputStyle
   ) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.upstream(width: 6)]),
            status: status(),
         )

      let expected = ("origi…", "~upst:origin/main")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `upstream truncated to width truncationMode: head`(
      outputStyle: OutputStyle
   ) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               components: [.upstream(width: 6, truncationMode: .head)],
            ),
            status: status(),
         )

      let expected = ("…/main", "~upst:origin/main")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `upstream truncated to width truncationMode: middle`(
      outputStyle: OutputStyle
   ) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               components: [.upstream(width: 6, truncationMode: .middle)],
            ),
            status: status(),
         )

      let expected = ("ori…in", "~upst:origin/main")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `upstream width zero`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.upstream(width: 0)]),
            status: status(),
         )

      let expected = ("…", "~upst:origin/main")
      expectMatch(expected, statusLine)
   }
}
