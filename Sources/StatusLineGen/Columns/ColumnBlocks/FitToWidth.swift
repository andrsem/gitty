// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Foundation
import Layout
import SW40

extension StatusLineGen {
   func fitToWidth(
      _ status: String,
      width: Int,
      mode: TruncationMode? = nil,
   ) -> String {
      switch (layout.outputStyle, status.count > width) {
      case (.linear, false): status
      case (.columnar, false): status.expanded(to: width)
      case (_, true):
         status
            .truncated(
               mode ?? layout.truncationMode,
               to: width,
               with: layout.symbols.truncator,
            )
      }
   }
}
