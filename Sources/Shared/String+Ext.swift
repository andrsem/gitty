// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Algorithms

extension StringProtocol {
   /// Trimming whitespace and new lines from both ends of the `String`.
   package var trimmedWN: String {
      String(trimming { $0.isWhitespace || $0.isNewline })
   }
}
