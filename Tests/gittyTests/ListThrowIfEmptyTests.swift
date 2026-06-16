// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import List
import Testing

@testable import gitty

@Test(.tags(.gitty))
func `list throw if empty test`() {
   let emptyList: List = []
   #expect(throws: (any Error).self) { try emptyList.throwIfEmpty() }

   let fullList: List = [Repo("~")]
   #expect(throws: Never.self) { try fullList.throwIfEmpty() }
}
