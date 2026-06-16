// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import SW40

extension StatusLineGen {
   static let unsortedPrefixID = "~"

   static func generateSortID(
      for component: SortComponent,
      with componentID: String,
      isAZ: Bool,
      sortOrder: [SortComponent],
   ) -> String {
      let sortComp =
         sortOrder
         .enumerated()
         .first { $0.element.rawValue.contains(component.rawValue) }

      guard let sortComp else { return unsortedPrefixID + componentID }

      let isComponentAZ = !sortComp.element.rawValue.hasPrefix("_")
      let forward = isComponentAZ ? "A" : "Z"
      let backward = isComponentAZ ? "Z" : "A"

      return
         sortComp
         .offset
         |> String.init
         |> { $0 + (isAZ ? forward : backward) + componentID }
   }
}
