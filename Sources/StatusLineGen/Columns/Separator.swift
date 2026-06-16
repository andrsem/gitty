// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout

extension StatusLineGen {
   func separator(
      _ symbol: String?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
      isHidden hidingConsecutive: Bool,
   ) -> Column {
      let symbol = (symbol ?? layout.symbols.separator)
      let styledSymbol =
         symbol
         .styledStatus(styles, fg: fg, bg: bg, emptyStr: emptyStr)
      let space = emptySpace(length: symbol.count)
      let result =
         switch layout.outputStyle {
         case .columnar: styledSymbol
         case .linear: hidingConsecutive ? space : styledSymbol
         }
      return (result, "")
   }
}
