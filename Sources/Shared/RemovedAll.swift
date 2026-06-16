// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

extension RangeReplaceableCollection {
   /// Returns a tuple containing a new collection that excludes the elements that meet the specified predicate, along with a collection of the removed elements.
   ///
   /// - Complexity: O(*n*), where *n* is the length of the collection.
   package func removedAll<E: Error>(
      where shouldBeRemoved: (Element) throws(E) -> Bool,
   ) throws(E) -> (kept: Self, removed: Self) {
      guard !isEmpty else { return (Self(), Self()) }

      var kept = Self()
      var removed = Self()

      let capacity = count / 2
      kept.reserveCapacity(capacity)
      removed.reserveCapacity(capacity)

      for element in self {
         try shouldBeRemoved(element)
            ? removed.append(element)
            : kept.append(element)
      }

      return (kept, removed)
   }
}
