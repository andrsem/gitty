// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eListSub))
struct `List Sub Scan E2E`: E2EConfigurable {
   @Test
   func `scan for repos`() async throws {
      expectMatch(
         """
         \(l2.appending(component: "repoL2").path())/
         \(l1.appending(component: "repoL1").path())/
         """,
         try await gitty("l -s \(l1.path())"),
      )

      expectMatch(
         """
         No repos were found at a depth of 1 at:
         \(l1.path())
         """,
         try await gitty("l -d 1 -s \(l1.path())"),
      )
   }


   @Test
   func `scan for repos at multiple paths`() async throws {
      let depth = 2
      expectMatch(
         """
         \(l1.appending(component: "repoL1").path())/
         """,
         try await gitty("l -d \(depth) -s \(l1.path())"),
      )

      expectMatch(
         """
         \(l2.appending(component: "repoL2").path())/
         """,
         try await gitty("l -d \(depth) -s \(l2.path())"),
      )

      expectMatch(
         """
         \(l2.appending(component: "repoL2").path())/
         \(l1.appending(component: "repoL1").path())/
         """,
         try await gitty("l -d \(depth) -s \(l1.path()) \(l2.path())"),
      )
   }


   @Test
   func `scan invalid path`() async throws {
      let path = l1.appending(path: "gobbledygook").path()
      expectMatch(
         "Path does not exist: \(path)",
         try await gitty("l -d 1 -s \(path)"),
      )
   }
}
