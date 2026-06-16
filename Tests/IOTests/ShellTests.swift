// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import IO

@Test(.tags(.io))
func `shell test`() async throws {
   let r1 = try await Shell.run(["echo hello | tr 'a-z' 'A-Z'"])
   #expect(r1.error.isEmpty)
   #expect(r1.output == "HELLO\n")

   let r2 = try await Shell.run(["printf 'abc' | rev; echo HI"])
   #expect(r2.error.isEmpty)
   let e2 = {
      #if os(macOS)
         "cba\nHI\n"
      #else
         "cbaHI\n"
      #endif
   }()
   #expect(r2.output == e2)

   let r3 = try await Shell.run(
      [
         #"echo "All args: $@"; echo "Arg 2: $2";"#,
         "_",
         "alpha",
         "beta",
         "gamma",
      ]
   )
   #expect(r3.error.isEmpty)
   #expect(
      r3.output == """
         All args: alpha beta gamma
         Arg 2: beta

         """
   )
}
