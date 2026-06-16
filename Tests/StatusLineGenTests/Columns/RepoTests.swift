// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import SW40
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Repo tests` {
   @Test(arguments: OutputStyle.allCases)
   func `repo no width specified`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.repo()]),
         status: status()
      )

      let expected = ("myRepo", "~repo:myRepo")

      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `repo expanded to width`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.repo(width: 18)]),
         status: status()
      )

      let expected =
         switch outputStyle {
         case .linear: ("myRepo", "~repo:myRepo")
         case .columnar: ("myRepo            ", "~repo:myRepo")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `repo truncated to width truncationMode: nil - global`(
      outputStyle: OutputStyle
   ) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.repo(width: 4)]),
         status: status()
      )

      let expected = ("myR…", "~repo:myRepo")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `repo truncated to width truncationMode: head`(outputStyle: OutputStyle)
   {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.repo(width: 4, truncationMode: .head)]
         ),
         status: status()
      )

      let expected = ("…epo", "~repo:myRepo")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `repo truncated to width truncationMode: middle`(
      outputStyle: OutputStyle
   ) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            components: [.repo(width: 4, truncationMode: .middle)]
         ),
         status: status()
      )

      let expected = ("my…o", "~repo:myRepo")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `repo width zero`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.repo(width: 0)]),
         status: status()
      )

      let expected = ("…", "~repo:myRepo")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `repo full path`(outputStyle: OutputStyle) {
      let url = URL(filePath: "/abc/xyz/myRepo")
      let statusLine = generateStatusLine(
         for: url,
         layout: layout(outputStyle, components: [.repo(fullPath: true)]),
         status: status()
      )

      let expected = (url.path(), "~repo:myRepo")
      expectMatch(expected, statusLine, trimLineEnds: true)
   }


   @Test(arguments: OutputStyle.allCases)
   func `repo sort order`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [.repo],
            components: [.repo(width: 4)]
         ),
         status: status()
      )

      let expected = ("myR…", "0Arepo:myRepo")
      expectMatch(expected, statusLine)
   }
}
