// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status
import Testing

@Suite(.tags(.statusLineGen))
struct `Modified tests` {
   private let symbol = layout().symbols.modified
   private let component = StatusComponent.modified()
   private static let xyChange = XY.Change.modified
   private let sortComponent = SortComponent.modified


   @Test(
      arguments: OutputStyle.allCases,
      xyChangeInAllPositions(xyChange),
   )
   func `modified tests`(outputStyle: OutputStyle, change: TrackedEntryChange) {
      testXYChanges(
         component: component,
         symbol: symbol,
         outputStyle: outputStyle,
         change: change,
         sortComponent: sortComponent,
      )
   }
}
