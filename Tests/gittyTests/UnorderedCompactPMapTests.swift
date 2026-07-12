// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import gitty

@Suite(.tags(.gitty))
struct `UnorderedCompactPMap tests` {
   @Test(
      arguments: [
         ["1", "2", "3"],
         ["1", "nil", "3", "4"],
         [],
         ["abc", "xyz"],
      ],
      [-1, 0, 1, 5, nil],
   )
   func `unorderedCompactPMap test`(array: [String], tasks: Int?) async throws {
      #expect(
         await array.unorderedCompactPMap(maxTasks: tasks) { Int($0) }.sorted()
            == array.compactMap { Int($0) }
      )
   }



   @Test(arguments: [
      [1, nil, 3],
      [1, 2, 3],
      [nil, nil],
      [],
   ])
   func `unorderedCompactPMap clean nils`(array: [Int?]) async throws {
      #expect(
         await array.unorderedCompactPMap(\.self).sorted()
            == array.compactMap(\.self)
      )
   }
}
