// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import TTS
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eListSub))
struct `List Sub Scan-Add E2E`: E2EConfigurable {
   @Test
   func `add multiple paths to list`() async throws {
      try await removeAllRepos()
      expectMatch(
         """
         The following 2 repos were added:
         • repoL1
         • repoL2
         """,
         try await gitty("l -A \(l1.path())"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `add multiple paths to list starting at different paths`() async throws
   {
      let depth = 2
      try await removeAllRepos()
      expectMatch(
         """
         The following repo was added:
         • repoL1
         """,
         try await gitty("l -d \(depth) -A \(l1.path())"),
      )

      try await removeAllRepos()
      expectMatch(
         """
         The following repo was added:
         • repoL2
         """,
         try await gitty("l -d \(depth) -A \(l2.path())"),
      )

      try await removeAllRepos()
      expectMatch(
         """
         The following 2 repos were added:
         • repoL1
         • repoL2
         """,
         try await gitty("l -d \(depth) -A \(l1.path()) \(l2.path())"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `add multiple paths to list verbosely`() async throws {
      try await removeAllRepos()
      expectMatch(
         """
         The following 2 repos were added:
         \("Repo: ".styles(.faint))\(l2.appending(component: "repoL2").path())/
         \("No tags.".styles(.faint))

         \("Repo: ".styles(.faint))\(l1.appending(component: "repoL1").path())/
         \("No tags.".styles(.faint))
         """,
         try await gitty("l -A \(l1.path()) -v"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `scan add where are no repos`() async throws {
      expectMatch(
         "No repos were added.",
         try await gitty("l -d 1 -A \(l1.path())"),
      )
   }


   @Test
   func `scan add invalid path`() async throws {
      let path = l1.appending(path: "gobbledygook").path()
      expectMatch(
         "Path does not exist: \(path)",
         try await gitty("l -d 1 -A \(path)"),
      )
   }


   @Test
   func `add multiple paths to list at depth 5`() async throws {
      try await removeAllRepos()
      expectMatch(
         """
         The following 3 repos were added:
         • repoL1
         • repoL2
         • repoOtherL4
         """,
         try await gitty("l -d 5 -A \(l1.path())"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2
         • repoOtherL4
         """,
         try await gitty("l"),
      )
   }
}
