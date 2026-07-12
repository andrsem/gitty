// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status
import Testing

@Suite(.tags(.statusLineGen))
struct `Deleted tests` {
   private let symbol = layout().symbols.deleted
   private let component = StatusComponent.deleted()
   private static let xyChange = XY.Change.deleted
   private let sortComponent = SortComponent.deleted


   @Test(
      arguments: OutputStyle.allCases,
      xyChangeInAllPositions(xyChange),
   )
   func `deleted tests`(outputStyle: OutputStyle, change: TrackedEntryChange) {
      testXYChanges(
         component: component,
         symbol: symbol,
         outputStyle: outputStyle,
         change: change,
         sortComponent: sortComponent,
      )
   }
}
