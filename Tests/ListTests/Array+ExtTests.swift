// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import List

@Suite
struct ArrayTests {
   enum SomeError: Error { case boom }

   @Test
   func uniqued() {
      let v1 = [1, 2].uniqued { _, _ in true }
      #expect(v1 == (unique: [1, 2], excluded: []))

      let v2 = [1, 1, 2].uniqued { _, _ in true }
      #expect(v2 == (unique: [1, 2], excluded: [1]))


      #expect(throws: SomeError.boom) {
         try [1, 2].uniqued { _, _ in throw SomeError.boom }
      }

      let initial = ["a cat", "a dog", "a cat"]
      let a = initial.uniqued { e, _ in e.contains("dog") }
      let b = initial.uniqued { e, _ in !e.contains("dog") }

      #expect(a == (["a dog"], ["a cat", "a cat"]))
      #expect(b == (["a cat"], ["a dog", "a cat"]))
      #expect(b.excluded != ["a cat", "a dog"])

      struct X: Hashable {
         init(_ name: String, _ value: Int) {
            self.name = name
            self.value = value
         }
         let name: String
         let value: Int
      }

      let initialX = [
         X("A", 5), X("B", 14), X("A", 1), X("B", 14), X("A", 3),
      ]

      let onlyDifferent = initialX.uniqued { _, _ in true }
      let onlyDifferentExpected = [
         X("A", 5), X("B", 14), X("A", 1), X("A", 3),
      ]
      #expect(onlyDifferent.unique == onlyDifferentExpected)

      #expect(onlyDifferent.excluded == [X("B", 14)])

      let onlyOver2 = initialX.uniqued { e, _ in e.value > 2 }
      #expect(onlyOver2.unique == [X("A", 5), X("B", 14), X("A", 3)])
      #expect(onlyOver2.excluded == [X("A", 1), X("B", 14)])

      let onlyUniqueNames =
         initialX.uniqued { e, seen in !seen.contains { $0.name == e.name } }

      #expect(onlyUniqueNames.unique == [X("A", 5), X("B", 14)])
      #expect(
         onlyUniqueNames.excluded == [X("A", 1), X("B", 14), X("A", 3)]
      )
   }
}
