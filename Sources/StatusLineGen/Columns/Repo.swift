// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Foundation
import Layout
import SW40

extension StatusLineGen {
   func repo(
      _ width: Int?,
      _ mode: TruncationMode?,
      _ fullPath: Bool?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      let value =
         (fullPath ?? false) ? repo.relativePath : repo.lastPathComponent

      let result = fitToWidth(value, width: width ?? value.count, mode: mode)
         .styledStatus(styles, fg: fg, bg: bg, emptyStr: emptyStr)

      let sortID = Self.generateSortID(
         for: .repo,
         with: "repo:" + repo.lastPathComponent,
         isAZ: layout.aZSort,
         sortOrder: layout.sortOrder,
      )

      return (result, sortID)
   }
}
