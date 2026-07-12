// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import SW40
import Status

extension StatusLineGen {
   func upstream(
      _ width: Int?,
      _ mode: TruncationMode?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      let upstream = status.upstream
      let width = width ?? upstream.count
      let result =
         switch (layout.outputStyle, upstream.isEmpty) {
         case (.linear, true):
            emptySpace(length: width)

         case (.linear, false):
            fitToWidth(upstream, width: width, mode: mode)
               .styledStatus(styles, fg: fg, bg: bg, emptyStr: emptyStr)

         case let (.columnar, e):
            fitToWidth(upstream, width: width, mode: mode)
               .styledStatus(
                  styles,
                  fg: fg,
                  bg: bg,
                  isVisible: !e,
                  emptyStr: emptyStr,
               )
         }

      let sortID = Self.generateSortID(
         for: .upstream,
         with: "upst:" + upstream,
         isAZ: layout.aZSort,
         sortOrder: layout.sortOrder,
      )

      return (result, sortID)
   }
}
