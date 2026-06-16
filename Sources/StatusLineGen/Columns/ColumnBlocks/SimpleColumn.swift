// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import SW40

extension StatusLineGen {
   func simpleColumn(
      _ symbol: String,
      sortID: SortComponent,
      styles: [TextStyle]?,
      fg: TextColor?,
      bg: TextColor?,
      hasChanges: Bool,
   ) -> Column {
      let id = Self.generateSortID(
         for: sortID,
         with: String(symbol.prefix(3)),
         isAZ: hasChanges |> layout.selectSortDirection,
         sortOrder: layout.sortOrder
      )

      let line =
         switch layout.outputStyle {
         case .linear:
            hasChanges
               ? symbol.styledStatus(styles, fg: fg, bg: bg, emptyStr: emptyStr)
               : emptySpace(length: symbol.count)

         case .columnar:
            symbol.styledStatus(
               styles,
               fg: fg,
               bg: bg,
               isVisible: hasChanges,
               emptyStr: emptyStr
            )
         }

      return (line, id)
   }
}
