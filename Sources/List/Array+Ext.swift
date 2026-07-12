// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

extension Array where Element: Hashable {
   /// Returns a tuple of unique elements satisfying the predicate and removed elements. The predicate provides access to unique elements for the current iteration through the seen parameter.
   ///
   /// - Complexity: O(*n*), where *n* is the length of the sequence.
   func uniqued<E: Error>(
      _ isIncluded: (Element, _ seen: Set<Element>) throws(E) -> Bool
   ) throws(E) -> (unique: Self, excluded: Self) {
      guard !isEmpty else { return ([], []) }

      var seen = Set<Element>()
      var unique = ContiguousArray<Element>()
      var excluded = ContiguousArray<Element>()

      let capacity = (count / 2) + 1
      unique.reserveCapacity(capacity)
      excluded.reserveCapacity(capacity)

      for element in self {
         if !seen.contains(element), try isIncluded(element, seen) {
            seen.insert(element)
            unique.append(element)
         } else {
            excluded.append(element)
         }
      }

      return (Array(unique), Array(excluded))
   }
}
