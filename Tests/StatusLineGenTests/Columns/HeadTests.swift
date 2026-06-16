// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import SW40
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Head Tests` {
   @Test(arguments: OutputStyle.allCases)
   func `head no width specified`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.head()]),
         status: status()
      )

      let expected = ("main", "~head:main")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `head expanded to width`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.head(width: 10)]),
         status: status()
      )

      let expected =
         switch outputStyle {
         case .linear: ("main", "~head:main")
         case .columnar: ("main      ", "~head:main")
         }

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `head truncated to width truncation mode: nil - use global`(
      outputStyle: OutputStyle
   ) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.head(width: 7)]),
         status: status(head: "myFeature")
      )

      let expected = ("myFeat…", "~head:myFeature")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `head truncated to width truncation mode: head`(
      outputStyle: OutputStyle
   ) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.head(width: 7, truncationMode: .head)]
         ),
         status: status(head: "myFeature")
      )

      let expected = ("…eature", "~head:myFeature")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `head truncated to width truncation mode: middle`(
      outputStyle: OutputStyle
   ) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.head(width: 7, truncationMode: .middle)]
         ),
         status: status(head: "myFeature")
      )

      let expected = ("myF…ure", "~head:myFeature")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `head width zero`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.head(width: 0)]),
         status: status(head: "myFeature")
      )

      let expected = ("…", "~head:myFeature")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `sort head first`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [.head, .added],
            components: [.added(), .head()]
         ),
         status: status()
      )

      let expected =
         switch outputStyle {
         case .linear: "0Ahead:main"
         case .columnar: "1ZA0Ahead:main"
         }

      expectMatch(expected, statusLine.sortID)
   }


   @Test(arguments: OutputStyle.allCases)
   func `sort head last`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [.added, .head],
            components: [.added(), .head()]
         ),
         status: status()
      )

      let expected =
         switch outputStyle {
         case .linear: "1Ahead:main"
         case .columnar: "0ZA1Ahead:main"
         }

      expectMatch(expected, statusLine.sortID)
   }


   @Test(arguments: OutputStyle.allCases)
   func `head with special characters`(outputStyle: OutputStyle) {
      let strangeBranch = "feat/🚀-issue-123"
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.head()]),
         status: status(head: strangeBranch)
      )

      let expected = (strangeBranch, "~head:\(strangeBranch)")
      expectMatch(expected, statusLine)
   }
}
