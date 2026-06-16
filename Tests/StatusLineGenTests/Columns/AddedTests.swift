// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status
import Testing

@Suite(.tags(.statusLineGen))
struct `Added tests` {
   private let symbol = layout().symbols.added
   private let component = StatusComponent.added()
   private static let xyChange = XY.Change.added
   private let sortComponent = SortComponent.added


   @Test(
      arguments: OutputStyle.allCases,
      xyChangeInAllPositions(xyChange)
   )
   func `added tests`(outputStyle: OutputStyle, change: TrackedEntryChange) {
      testXYChanges(
         component: component,
         symbol: symbol,
         outputStyle: outputStyle,
         change: change,
         sortComponent: sortComponent
      )
   }
}
