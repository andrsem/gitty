// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Configurator
import Diffy
import Foundation
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eListSub))
struct `List Sub Other E2E`: E2EConfigurable {
   @Test
   func `broken list`() async throws {
      let list = debugConfigBase.appending(
         components: Self.testDir,
         "list.json",
      )
      try Data().write(to: list)

      let res = try await gitty("l")
      let exp = {
         #if os(macOS)
            "Error: Failed to read list JSON file. The given data was not valid JSON. Unexpected end of file"
         #else
            "Error: Failed to read list JSON file. The given data was not valid JSON. "
         #endif
      }()
      expectMatch(exp, res)
   }


   @Test
   func `multiple list actions at once not allowed`() async throws {
      let r = try await gitty("l -a cat -r bird")
      let e =
         "Error: Multiple list actions (--add, --remove) are not allowed at the same time."
      #expect(r.contains(e))
   }
}



func expectListIsEmpty(
   _ gitty: (String) async throws -> String,
   command: String = "l",
   _ sourceLocation: SourceLocation = #_sourceLocation,
) async throws {
   let result = try await gitty(command)
   #expect(
      result.contains("The list is empty."),
      sourceLocation: sourceLocation,
   )
   #expect(
      result.contains("Add Git repos to the list:"),
      sourceLocation: sourceLocation,
   )
}
