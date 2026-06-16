// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status

extension StatusLineGen {
   func pull(
      _ hideCount: Bool?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      columnWithCount(
         status.pullCount,
         for: layout.symbols.pull,
         sortID: .pull,
         fg: fg,
         bg: bg,
         styles: styles,
         hideCount: hideCount,
      )
   }


   func push(
      _ hideCount: Bool?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      columnWithCount(
         status.pushCount,
         for: layout.symbols.push,
         sortID: .push,
         fg: fg,
         bg: bg,
         styles: styles,
         hideCount: hideCount,
      )
   }
}
