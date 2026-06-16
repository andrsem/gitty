// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT


import Layout

extension Layout {
   func selectSortDirection(_ isAZ: Bool) -> Bool {
      aZSort ? isAZ : !isAZ
   }
}
