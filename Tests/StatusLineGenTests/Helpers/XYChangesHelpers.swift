// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Status
import TTS
import Testing

@testable import StatusLineGen

func xyChangeInAllPositions(
   _ change: XY.Change
) -> [TrackedEntryChange] {
   [
      .orcuChange(
         xy: .init(index: change, workingTree: .unmodified),
         sub: .notSubmodule
      ),

      .orcuChange(
         xy: .init(index: .unmodified, workingTree: change),
         sub: .notSubmodule
      ),

      .orcuChange(
         xy: .init(index: change, workingTree: change),
         sub: .notSubmodule
      ),
   ]
}


func testXYChanges(
   component: StatusComponent,
   symbol: String,
   outputStyle: OutputStyle,
   change: TrackedEntryChange,
   sortComponent: SortComponent,
   sourceLocation: SourceLocation = #_sourceLocation,
) {
   testXYSort(
      component: component,
      symbol: symbol,
      outputStyle: outputStyle,
      change: change,
      sortComponent: sortComponent,
      sourceLocation: sourceLocation
   )


   testXYNoChanges(
      component: component,
      symbol: symbol,
      outputStyle: outputStyle,
      sourceLocation: sourceLocation
   )


   testXYWithChange(
      component: component,
      symbol: symbol,
      outputStyle: outputStyle,
      change: change,
      sourceLocation: sourceLocation
   )

   testXYWithChange(
      component: component,
      symbol: symbol,
      outputStyle: outputStyle,
      change: change,
      sortOrder: [sortComponent],
      sourceLocation: sourceLocation
   )
}


private func testXYNoChanges(
   component: StatusComponent,
   symbol: String,
   outputStyle: OutputStyle,
   sourceLocation: SourceLocation = #_sourceLocation
) {
   let statusLine = generateStatusLine(
      for: URL(filePath: "myURL"),
      layout: layout(outputStyle, components: [component]),
      status: cleanStatus
   )

   let expected =
      switch outputStyle {
      case .linear: ("", "")
      case .columnar: (" ", "~\(symbol)")
      }

   expectMatch(
      expected,
      statusLine,
      sourceLocation: sourceLocation
   )
}


private func testXYWithChange(
   component: StatusComponent,
   symbol: String,
   outputStyle: OutputStyle,
   change: TrackedEntryChange,
   sortOrder: [SortComponent] = [],
   sourceLocation: SourceLocation = #_sourceLocation,
) {
   let statusWithChange = status(changedEntries: [change])
   let layoutWithNoSortOrder = layout(outputStyle, components: [component])
   let statusLine = generateStatusLine(
      for: URL(filePath: "myURL"),
      layout: layoutWithNoSortOrder,
      status: statusWithChange
   )

   let defaultSortIDWhenNoSortOrder = "~\(symbol)"

   expectMatch(
      (symbol, defaultSortIDWhenNoSortOrder),
      statusLine,
      sourceLocation: sourceLocation
   )

   let layoutWithSortOrder = layout(
      outputStyle,
      sortOrder: sortOrder,
      components: [component]
   )
   let statusLineWithSortOrder = generateStatusLine(
      for: URL(filePath: "myURL"),
      layout: layoutWithSortOrder,
      status: statusWithChange
   )

   let sortIDForSortOrder = (sortOrder.isEmpty ? "~" : "0A") + symbol


   expectMatch(
      (symbol, sortIDForSortOrder),
      statusLineWithSortOrder,
      sourceLocation: sourceLocation
   )
}


private func testXYSort(
   component: StatusComponent,
   symbol: String,
   outputStyle: OutputStyle,
   change: TrackedEntryChange,
   sortComponent: SortComponent,
   sourceLocation: SourceLocation = #_sourceLocation,
) {
   let statusLine = generateStatusLine(
      for: URL(filePath: "myRepo"),
      layout: layout(
         outputStyle,
         sortOrder: [sortComponent],
         components: [component]
      ),
      status: status(changedEntries: [change])
   )

   let ascDescSign = sortComponent.rawValue.hasPrefix("_") ? "Z" : "A"

   let expected = (symbol, "0\(ascDescSign)\(symbol)")
   expectMatch(
      expected,
      statusLine,
      sourceLocation: sourceLocation
   )
}
