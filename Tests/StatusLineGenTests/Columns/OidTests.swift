// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Status
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Oid tests` {
   @Test(arguments: OutputStyle.allCases)
   func `oid test`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.oid()]),
         status: status()
      )
      let oid = status().oid.prefix(7)
      let expected = ("\(oid)", "~oid:\(oid)")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `oid min length test`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.oid(length: 0)]),
         status: status()
      )
      let oid = status().oid.prefix(4)
      let expected = ("\(oid)", "~oid:\(oid)")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `oid max length test`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(outputStyle, components: [.oid(length: 9999)]),
         status: status()
      )
      let oidFull = status().oid

      let expected = ("\(oidFull)", "~oid:\(oidFull)")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `sort oid first`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [.oid, .added],
            components: [.added(), .oid(length: 7)]
         ),
         status: status()
      )

      let expected =
         switch outputStyle {
         case .linear: "0Aoid:fbc7d6a"
         case .columnar: "1ZA0Aoid:fbc7d6a"
         }

      expectMatch(expected, statusLine.sortID)
   }


   @Test(arguments: OutputStyle.allCases)
   func `sort oid last`(outputStyle: OutputStyle) {
      let statusLine = generateStatusLine(
         for: URL(filePath: "myRepo"),
         layout: layout(
            outputStyle,
            sortOrder: [.added, .oid],
            components: [.added(), .oid(length: 7)]
         ),
         status: status()
      )

      let expected =
         switch outputStyle {
         case .linear: "1Aoid:fbc7d6a"
         case .columnar: "0ZA1Aoid:fbc7d6a"
         }

      expectMatch(expected, statusLine.sortID)
   }
}
