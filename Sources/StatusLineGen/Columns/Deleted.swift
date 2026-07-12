// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status

extension StatusLineGen {
   func deleted(
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      simpleColumn(
         layout.symbols.deleted,
         sortID: .deleted,
         styles: styles,
         fg: fg,
         bg: bg,
         hasChanges: status.changedEntries.containsChange(.deleted),
      )
   }
}
