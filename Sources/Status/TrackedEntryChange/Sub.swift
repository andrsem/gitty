// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package enum Sub {
   case notSubmodule
   case isSubmodule(
      isCommitChanged: Bool,
      hasTrackedChanges: Bool,
      hasUntrackedChanges: Bool,
   )


   init?(from raw: (some StringProtocol)?) {
      guard
         let raw,
         raw.count == 4
      else { return nil }

      let result: Self? =
         switch raw.first {
         case "N": .notSubmodule
         case "S":
            .isSubmodule(
               isCommitChanged: raw.contains("C"),
               hasTrackedChanges: raw.contains("M"),
               hasUntrackedChanges: raw.contains("U"),
            )
         default: nil
         }

      guard let result else { return nil }

      self = result
   }
}


extension Sub: Hashable {}
extension Sub: Sendable {}
