// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import TTS
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Pull pull tests` {
   // MARK: - Push

   @Test(arguments: OutputStyle.allCases)
   func `push test zero`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.push()]),
            status: status(pushCount: 0),
         )

      let expected =
         switch outputStyle {
         case .linear: ("", "")
         case .columnar: ("   ", "~↑")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `push test one`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.push()]),
            status: status(pushCount: 1),
         )

      let expected =
         switch outputStyle {
         case .linear: ("↑1", "~↑")
         case .columnar: ("↑1 ", "~↑")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `push test exceeding max limit`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               maxCount: 9,
               maxCountStyle: .init(fg: .red),
               components: [.push()],
            ),
            status: status(pushCount: 100),
         )

      let expected = ("↑" + "9".fg(.red), "~↑")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `push test hide count`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.push(hideCount: true)]),
            status: status(pushCount: 1),
         )

      let expected = ("↑", "~↑")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `push sort ascending`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               sortOrder: [.push],
               components: [.push()],
            ),
            status: status(pushCount: 1),
         )

      let expected =
         switch outputStyle {
         case .linear: ("↑1", "0A↑")
         case .columnar: ("↑1 ", "0A↑")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `push sort descending`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               sortOrder: [._push],
               components: [.push()],
            ),
            status: status(pushCount: 1),
         )

      let expected =
         switch outputStyle {
         case .linear: ("↑1", "0Z↑")
         case .columnar: ("↑1 ", "0Z↑")
         }
      expectMatch(expected, statusLine)
   }


   // MARK: - Pull

   @Test(arguments: OutputStyle.allCases)
   func `pull test zero`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.pull()]),
            status: status(pullCount: 0),
         )

      let expected =
         switch outputStyle {
         case .linear: ("", "")
         case .columnar: ("   ", "~↓")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `pull test one`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.pull()]),
            status: status(pullCount: 1),
         )

      let expected =
         switch outputStyle {
         case .linear: ("↓1", "~↓")
         case .columnar: ("↓1 ", "~↓")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `pull test exceeding max limit`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               maxCount: 9,
               maxCountStyle: .init(fg: .red),
               components: [.pull()],
            ),
            status: status(pullCount: 100),
         )

      let expected = ("↓" + "9".fg(.red), "~↓")
      expectMatch(statusLine, expected)
   }


   @Test(arguments: OutputStyle.allCases)
   func `pull test hide count`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(outputStyle, components: [.pull(hideCount: true)]),
            status: status(pullCount: 1),
         )

      let expected = ("↓", "~↓")
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `pull sort ascending`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               sortOrder: [.pull],
               components: [.pull()],
            ),
            status: status(pullCount: 1),
         )

      let expected =
         switch outputStyle {
         case .linear: ("↓1", "0A↓")
         case .columnar: ("↓1 ", "0A↓")
         }
      expectMatch(expected, statusLine)
   }


   @Test(arguments: OutputStyle.allCases)
   func `pull sort descending`(outputStyle: OutputStyle) {
      let statusLine =
         generateStatusLine(
            for: URL(filePath: "myRepo"),
            layout: layout(
               outputStyle,
               sortOrder: [._pull],
               components: [.pull()],
            ),
            status: status(pullCount: 1),
         )

      let expected =
         switch outputStyle {
         case .linear: ("↓1", "0Z↓")
         case .columnar: ("↓1 ", "0Z↓")
         }
      expectMatch(expected, statusLine)
   }
}
