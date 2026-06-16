// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Foundation

extension StringProtocol {
   /// Compares the string and the given string as sorted by the Finder in ascending order.
   public func azCompare(_ string: Self) -> Bool {
      Shared.azCompare(self, string)
   }
}



/// Compares two strings as sorted by the Finder in ascending order.
public func azCompare<T: StringProtocol>(_ lhs: T, _ rhs: T) -> Bool {
   lhs.localizedStandardCompare(rhs) != .orderedDescending
}
