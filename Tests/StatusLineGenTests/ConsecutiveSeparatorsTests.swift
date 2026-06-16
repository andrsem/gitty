// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Consecutive separators tests` {
   private func layoutWithSeparators(_ outputStyle: OutputStyle) -> Layout {
      layout(
         outputStyle,
         components: [
            .separator(),
            .separator(),
            .separator(),
            .repo(),

            .separator(),
            .separator(),
            .separator(),
            .separator(),
         ]
      )
   }


   @Test
   private func `no same consecutive separators in linear`() {
      let result = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: layoutWithSeparators(.linear),
         status: cleanStatus
      )

      expectMatch(" " + "myURL" + " ", result.line)
   }


   @Test
   private func `overridden consecutive separators in linear`() {
      let result = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: layout(
            .linear,
            components: [
               .separator(symbol: "^"),
               .separator(),
               .separator(),
               .repo(),

               .separator(),
               .separator(symbol: "&"),
               .separator(),
               .separator(),
            ]
         ),
         status: cleanStatus
      )

      expectMatch(
         "^ myURL & ",
         result.line,
      )
   }


   @Test
   private func `consecutive separators in columnar`() {
      let result = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: layoutWithSeparators(.columnar),
         status: cleanStatus
      )

      let separator = " "
      let expected =
         String(repeating: separator, count: 3)
         + "myURL"
         + String(repeating: separator, count: 4)
      expectMatch(expected, result.line)
   }


   @Test
   private func `overridden consecutive separators in columnar`() {
      let result = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: layout(
            .columnar,
            components: [
               .separator(symbol: "^"),
               .separator(),
               .separator(),
               .repo(),

               .separator(),
               .separator(symbol: "&"),
               .separator(),
               .separator(),
            ]
         ),
         status: cleanStatus
      )

      expectMatch(
         "^  \("myURL") &  ",
         result.line,
      )
   }
}
