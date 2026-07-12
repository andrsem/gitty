// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Status
import TTS
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Clean or Dirty status tests` {
   private let cleanSymbol = layout().symbols.clean
   private let dirtySymbol = layout().symbols.dirty


   @Test(arguments: OutputStyle.allCases)
   func `clean status with clean symbol`(outputStyle: OutputStyle) {
      let cleanResult = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: layout(
            outputStyle,
            components: [.cleanOrDirty(showDirty: true)],
         ),
         status: cleanStatus,
      )

      expectMatch(cleanSymbol, cleanResult.line)
   }


   @Test(arguments: OutputStyle.allCases)
   func `dirty status with dirty symbol`(outputStyle: OutputStyle) {
      let dirtyStatus = status(changedEntries: [.ignored])
      let dirtyResultWith = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: layout(
            outputStyle,
            components: [.cleanOrDirty(showDirty: true)],
         ),
         status: dirtyStatus,
      )

      expectMatch(dirtySymbol, dirtyResultWith.line)
   }


   @Test(arguments: OutputStyle.allCases)
   func `dirty without symbol`(outputStyle: OutputStyle) {
      let dirtyStatus = status(changedEntries: [.untracked])
      let expectedDirty =
         switch outputStyle {
         case .linear: ""
         case .columnar: " "
         }

      let dirtyResult = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: layout(
            outputStyle,
            components: [.cleanOrDirty(showDirty: false)],
         ),
         status: dirtyStatus,
      )

      expectMatch(expectedDirty, dirtyResult.line)
   }


   typealias Case = (
      showDirty: Bool,
      cleanSymbol: String,
      dirtySymbol: String,
      expectedCleanLinear: String,
      expectedCleanColumnar: String,
      expectedDirtyLinear: String,
      expectedDirtyColumnar: String
   )
   // swift-format-ignore
   static let cases: [Case] = [
      (false, "o",   "a",   "o",   "o",   "",    " "  ),
      (false, "o",   "-a-", "o",   "o",   "",    " "  ),
      (false, " o ", "-a-", " o ", " o ", "",    "   "),
      (false, " o ", "a",   " o ", " o ", "",    "   "),
      (true,  "o",   "a",   "o",   "o",   "a",   "a"  ),
      (true,  "o",   "-a-", "o",   "o  ", "-a-", "-a-"),
      (true,  "-o-", "a",   "-o-", "-o-", "a",   "a  "),
      (true,  "-o-", "a",   "-o-", "-o-", "a",   "a  "),
   ]

   @Test(arguments: OutputStyle.allCases, cases)
   func `symbols have different length showDirty true`(
      outputStyle: OutputStyle,
      testCase: Case,
   ) {
      let modifiedSymbol = "M"
      let _genStatusLine = {
         generateStatusLine(
            for: URL(filePath: "myURL"),
            layout: layout(
               outputStyle,
               symbols: symbols(
                  clean: testCase.cleanSymbol,
                  dirty: testCase.dirtySymbol,
                  modified: modifiedSymbol,
               ),
               components: [
                  .cleanOrDirty(showDirty: testCase.showDirty),
                  .modified(),
               ],
            ),
            status: $0,
         )
      }
      let expectedDirty =
         switch outputStyle {
         case .linear: testCase.expectedDirtyLinear
         case .columnar: testCase.expectedDirtyColumnar
         }
      let expectedClean =
         switch outputStyle {
         case .linear: testCase.expectedCleanLinear
         case .columnar: testCase.expectedCleanColumnar
         }
      let modifiedCleanSymbol =
         switch outputStyle {
         case .linear: ""
         case .columnar: String(repeating: " ", count: modifiedSymbol.count)
         }

      let dirtyStatus = status(
         changedEntries: [
            .orcuChange(
               xy: .init(index: .modified, workingTree: .unmodified),
               sub: .notSubmodule,
            )
         ]
      )
      let dirtyResult = _genStatusLine(dirtyStatus)
      expectMatch(expectedDirty + modifiedSymbol, dirtyResult.line)

      let cleanResult = _genStatusLine(status())
      expectMatch(expectedClean + modifiedCleanSymbol, cleanResult.line)

      if outputStyle == .columnar {
         #expect(dirtyResult.line.count == cleanResult.line.count)
      }
   }
}
