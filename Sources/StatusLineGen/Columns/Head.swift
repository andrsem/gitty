// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import SW40
import Status

extension StatusLineGen {
   func head(
      _ width: Int?,
      _ mode: TruncationMode?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      let sortID =
         Self.generateSortID(
            for: .head,
            with: "head:" + status.head,
            isAZ: layout.aZSort,
            sortOrder: layout.sortOrder
         )

      return fitToWidth(
         status.head,
         width: width ?? status.head.count,
         mode: mode
      )
      .styledStatus(styles, fg: fg, bg: bg, emptyStr: emptyStr)
         |> { ($0, sortID) }
   }
}
