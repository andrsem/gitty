// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import List

extension List {
   func throwIfEmpty() throws {
      guard !isEmpty else {
         throw CleanExit.message(List.emptyListDescription)
      }
   }
}
