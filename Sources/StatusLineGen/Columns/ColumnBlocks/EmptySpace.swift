// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout

extension StatusLineGen {
   func emptySpace(length: Int) -> String {
      switch layout.outputStyle {
      case .columnar: String(repeating: " ", count: length)
      case .linear: ""
      }
   }
}
