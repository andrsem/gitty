// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package struct XY {
   package let index: Change
   package let workingTree: Change


   package init(index: Change, workingTree: Change) {
      self.index = index
      self.workingTree = workingTree
   }


   package func contains(_ change: Change) -> Bool {
      index == change || workingTree == change
   }


   package enum Change: String, CaseIterable {
      case added
      case copied
      case deleted
      case modified
      case renamed
      case typeChange
      case unmerged
      case unmodified


      fileprivate init?(_ character: Character?) {
         let result: Self? =
            switch character {
            case "A": .added
            case "C": .copied
            case "D": .deleted
            case "M": .modified
            case "U": .unmerged
            case "R": .renamed
            case "T": .typeChange
            case ".": .unmodified
            default: nil
            }

         guard let result else { return nil }

         self = result
      }
   }
}


extension XY {
   init?(from xy: (some StringProtocol)?) {
      guard
         let xy,
         xy.count == 2,
         let index = Change(xy.first),
         let workingTree = Change(xy.last)
      else { return nil }

      self.index = index
      self.workingTree = workingTree
   }
}


extension XY: Hashable {}
extension XY: Sendable {}

extension XY.Change: Sendable {}
