// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Count Statuses tests` {
   static let countStatus = status(pullCount: 1, pushCount: 100, stashCount: 10)
   static func layoutWithCount(
      _ outputStyle: OutputStyle,
      countMode: CountMode = .trailing,
      maxCount: Int = 99,
      countHidden: Bool? = nil,
   ) -> Layout {
      layout(
         outputStyle,
         countMode: countMode,
         maxCount: maxCount,
         components: [
            .pull(hideCount: countHidden),
            .separator(symbol: "-"),
            .push(hideCount: countHidden),
            .separator(symbol: "-"),
            .stashes(hideCount: countHidden),
         ]
      )
   }


   @Test(arguments: [false, nil])
   func `columnar with count`(countHidden: Bool?) {
      let line = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: Self.layoutWithCount(.columnar, countHidden: countHidden),
         status: Self.countStatus
      )
      .line

      expectMatch("↓1 -↑99-#10", line)
   }


   @Test(arguments: [false, nil])
   func `columnar with count mode leading`(countHidden: Bool?) {
      let line = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout:
            Self.layoutWithCount(
               .columnar,
               countMode: .leading,
               countHidden: countHidden
            ),
         status: Self.countStatus
      )
      .line

      expectMatch("1 ↓-99↑-10#", line)
   }


   @Test(arguments: [-1, 0, .min, 1])
   func `maxCount is always a positive integer and at least 1`(count: Int) {
      let line = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: Self.layoutWithCount(.columnar, maxCount: count),
         status: Self.countStatus
      )
      .line

      expectMatch("↓1-↑1-#1", line)
   }


   @Test
   func `columnar with hidden count`() {
      let line = generateStatusLine(
         for: URL(filePath: "myURL"),
         layout: Self.layoutWithCount(.columnar, countHidden: true),
         status: Self.countStatus
      )
      .line

      expectMatch("↓-↑-#", line)
   }
}
