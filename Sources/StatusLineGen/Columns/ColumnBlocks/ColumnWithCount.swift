// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import SW40

extension StatusLineGen {
   func columnWithCount(
      _ count: Int,
      for symbol: String,
      sortID: SortComponent,
      fg: TextColor?,
      bg: TextColor?,
      styles: [TextStyle]?,
      hideCount: Bool?,
   ) -> Column {
      let maxCount = max(1, layout.maxCount)
      let symbolLength = symbol.count
      let requiredLength = symbolLength + String(maxCount).count
      let countStr = String(count.clamped(to: .zero ... maxCount))
      let spacesCount =
         max(.zero, requiredLength - countStr.count - symbolLength)

      let fillSpace =
         layout.outputStyle == .columnar
         ? String(repeating: " ", count: spacesCount)
         : ""

      let countStyle =
         count > maxCount
         ? layout.maxCountStyle
         : CountStyle(fg: fg, bg: bg, styles: styles)

      let isColumnVisible = count != .zero
      let styledCountStr =
         countStr
         .styledStatus(
            countStyle.styles,
            fg: countStyle.fg,
            bg: countStyle.bg,
            isVisible: isColumnVisible,
            emptyStr: emptyStr,
         )

      let symbolWithCount =
         switch layout.countMode {
         case .leading: styledCountStr + fillSpace + symbol
         case .trailing: symbol + styledCountStr + fillSpace
         }

      let result =
         ((hideCount ?? false) ? symbol : symbolWithCount)
         .styledStatus(
            styles,
            fg: fg,
            bg: bg,
            isVisible: isColumnVisible,
            emptyStr: emptyStr,
         )

      let sort = Self.generateSortID(
         for: sortID,
         with: symbol,
         isAZ: (count != .zero) |> layout.selectSortDirection,
         sortOrder: layout.sortOrder,
      )

      return (result, sort)
   }
}
