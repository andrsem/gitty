// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import SW40
import Status

extension StatusLineGen {
   func cleanOrDirty(
      _ showDirty: Bool?,
      _ cleanFg: TextColor?,
      _ cleanBg: TextColor?,
      _ cleanS: [TextStyle]?,
      _ dirtyFg: TextColor?,
      _ dirtyBg: TextColor?,
      _ dirtyS: [TextStyle]?,
   ) -> Column {
      let showDirty = showDirty ?? false
      let width =
         showDirty
         ? max(layout.symbols.clean.count, layout.symbols.dirty.count)
         : layout.symbols.clean.count

      let result =
         switch (status.isClean, showDirty) {
         case (true, _):
            fitToWidth(layout.symbols.clean, width: width)
               .styledStatus(
                  cleanS,
                  fg: cleanFg,
                  bg: cleanBg,
                  emptyStr: emptyStr
               )
         case (false, true):
            fitToWidth(layout.symbols.dirty, width: width)
               .styledStatus(
                  dirtyS,
                  fg: dirtyFg,
                  bg: dirtyBg,
                  emptyStr: emptyStr
               )
         case (false, false):
            emptySpace(length: width)
         }

      let sortID = Self.generateSortID(
         for: .clean,
         with: "c&d:",
         isAZ: status.isClean |> layout.selectSortDirection,
         sortOrder: layout.sortOrder
      )

      return (result, sortID)
   }
}
