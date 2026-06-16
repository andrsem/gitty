// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import Status

extension StatusLineGen {
   func noUpstream(
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      simpleColumn(
         layout.symbols.noUpstream,
         sortID: .noUpstream,
         styles: styles,
         fg: fg,
         bg: bg,
         hasChanges: status.upstream.isEmpty
      )
   }
}
