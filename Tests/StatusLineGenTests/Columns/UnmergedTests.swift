// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status
import Testing

@Suite(.tags(.statusLineGen))
struct `Unmerged tests` {
   private let symbol = layout().symbols.unmerged
   private let component = StatusComponent.unmerged()
   private static let xyChange = XY.Change.unmerged
   private let sortComponent = SortComponent.unmerged


   @Test(
      arguments: OutputStyle.allCases,
      xyChangeInAllPositions(xyChange)
   )
   func `unmerged tests`(outputStyle: OutputStyle, change: TrackedEntryChange) {
      testXYChanges(
         component: component,
         symbol: symbol,
         outputStyle: outputStyle,
         change: change,
         sortComponent: sortComponent
      )
   }
}
