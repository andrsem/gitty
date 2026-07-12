// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Aliases
import Diffy
import Foundation
import Testing

@testable import Configurator

extension Tag {
   @Tag
   static var configurator: Self
}

@Test(.tags(.configurator))
func `validate initial aliases`() throws {
   let initialAliases = try Aliases.read { Aliases.initial }
   let expectedAliases: [Alias] = [
      try! Alias(
         "fetch",
         args: ["git fetch"],
         details: "Fetch git changes",
         flags: [.parallel, .quiet],
         status: [],
         delay: .zero,
         sort: .az,
      ),
      try! Alias(
         "pull",
         args: ["git pull"],
         details: "Pull git changes",
         flags: [.parallel, .quiet],
         status: [.needsPull],
         delay: .zero,
         sort: .az,
      ),
      try! Alias(
         "push",
         args: ["git push"],
         details: "Push git changes",
         flags: [.parallel, .quiet],
         status: [.needsPush],
         delay: .zero,
         sort: .az,
      ),
   ]

   #expect(expectedAliases == initialAliases)
}
