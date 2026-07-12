// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Algorithms
import Foundation
import Layout
import SW40

extension StatusLineGen {
   func custom(
      _ command: String,
      _ sortID: String?,
      _ width: Int?,
      _ mode: TruncationMode?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      func formColumn(for custom: CustomOutput) -> Column {
         let out =
            custom.output.trimming(while: \.isNewline)
            |> { $0.isEmpty ? "" : $0 }
            |> String.init

         let styled = fitToWidth(out, width: width ?? out.count, mode: mode)
            .styledStatus(styles, fg: fg, bg: bg, emptyStr: emptyStr)

         let sortID =
            Self.generateSortID(
               for: .custom(sortID),
               with: "cust:" + out,
               isAZ: layout.aZSort,
               sortOrder: layout.sortOrder,
            )

         return (styled, sortID)
      }

      return
         custom.first { command == $0.command }
         .map(formColumn)
         ?? ("", "")
   }
}
