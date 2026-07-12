// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status
import Testing

@Suite(.tags(.statusLineGen))
struct `Renamed tests` {
   private let symbol = layout().symbols.renamed
   private let component = StatusComponent.renamed()
   private static let xyChange = XY.Change.renamed
   private let sortComponent = SortComponent.renamed


   @Test(
      arguments: OutputStyle.allCases,
      xyChangeInAllPositions(xyChange),
   )
   func `renamed tests`(outputStyle: OutputStyle, change: TrackedEntryChange) {
      testXYChanges(
         component: component,
         symbol: symbol,
         outputStyle: outputStyle,
         change: change,
         sortComponent: sortComponent,
      )
   }
}
