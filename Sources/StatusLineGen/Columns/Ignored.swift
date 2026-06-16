// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status

extension StatusLineGen {
   func ignored(
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      simpleColumn(
         layout.symbols.ignored,
         sortID: .ignored,
         styles: styles,
         fg: fg,
         bg: bg,
         hasChanges: status.changedEntries.containsIgnored()
      )
   }
}
