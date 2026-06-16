// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status
import Testing

@Suite(.tags(.statusLineGen))
struct `Copied tests` {
   private let symbol = layout().symbols.copied
   private let component = StatusComponent.copied()
   private static let xyChange = XY.Change.copied
   private let sortComponent = SortComponent.copied


   @Test(
      arguments: OutputStyle.allCases,
      xyChangeInAllPositions(xyChange)
   )
   func `copied tests`(outputStyle: OutputStyle, change: TrackedEntryChange) {
      testXYChanges(
         component: component,
         symbol: symbol,
         outputStyle: outputStyle,
         change: change,
         sortComponent: sortComponent
      )
   }
}
