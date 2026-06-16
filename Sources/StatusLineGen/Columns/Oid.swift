// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import SW40
import Status

extension StatusLineGen {
   func oid(
      _ length: Int?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      let length = (length ?? 7).clamped(to: 4 ... 40)
      let oid = length |> status.oid.prefix |> String.init
      let sortID =
         Self.generateSortID(
            for: .oid,
            with: "oid:" + oid,
            isAZ: layout.aZSort,
            sortOrder: layout.sortOrder
         )

      return fitToWidth(oid, width: length)
         .styledStatus(styles, fg: fg, bg: bg, emptyStr: emptyStr)
         |> { ($0, sortID) }
   }
}
