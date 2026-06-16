// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status
import Testing

@Suite(.tags(.statusLineGen))
struct `Type change tests` {
   private let symbol = layout().symbols.typeChange
   private let component = StatusComponent.typeChange()
   private static let xyChange = XY.Change.typeChange
   private let sortComponent = SortComponent.typeChange


   @Test(
      arguments: OutputStyle.allCases,
      xyChangeInAllPositions(xyChange)
   )
   func `type change tests`(
      outputStyle: OutputStyle,
      change: TrackedEntryChange
   ) {
      testXYChanges(
         component: component,
         symbol: symbol,
         outputStyle: outputStyle,
         change: change,
         sortComponent: sortComponent
      )
   }
}
