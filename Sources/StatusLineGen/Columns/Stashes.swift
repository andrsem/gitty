// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status

extension StatusLineGen {
   func stashes(
      _ hideCount: Bool?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      columnWithCount(
         status.stashCount,
         for: layout.symbols.stashes,
         sortID: .stashes,
         fg: fg,
         bg: bg,
         styles: styles,
         hideCount: hideCount,
      )
   }
}
