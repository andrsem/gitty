// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eRunSub))
struct `Run Sub Alias E2E`: E2EConfigurable {
   // MARK: - gitty run [--aliases] [--compact]

   @Test
   func `gitty is initialized with initial aliases`() async throws {
      expectMatch(
         """
         ALIASES:

         Name:      fetch
         Arguments: git fetch
         Details:   Fetch git changes
         Flags:     parallel, quiet
         Filters:   
         Delay:     0 ms
         Sort:      az

         Name:      pull
         Arguments: git pull
         Details:   Pull git changes
         Flags:     parallel, quiet
         Filters:   needs-pull
         Delay:     0 ms
         Sort:      az

         Name:      push
         Arguments: git push
         Details:   Push git changes
         Flags:     parallel, quiet
         Filters:   needs-push
         Delay:     0 ms
         Sort:      az
         """,
         try await gitty("r --aliases"),
      )
   }


   @Test
   func `gitty is initialized with initial aliases compact`() async throws {
      expectMatch(
         """
         ALIASES:

         Name: fetch
         Args: git fetch

         Name: pull
         Args: git pull

         Name: push
         Args: git push
         """,
         try await gitty("r --aliases --compact"),
      )
   }
}
