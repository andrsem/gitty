// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import TTS
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eListSub))
struct `List Sub Add E2E`: E2EConfigurable {
   // MARK: - gitty list [--add <path>...] [--verbose]


   @Test
   func `add Git repo path to the empty list`() async throws {
      try await removeAllRepos()
      let l1Repo = l1.appending(component: "repoL1").path()
      expectMatch(
         """
         The following repo was added:
         • repoL1
         """,
         try await gitty("l -a \(l1Repo)"),
      )

      expectMatch(
         "• repoL1",
         try await gitty("l"),
      )
   }


   @Test
   func `add multiple Git repos to the empty list`() async throws {
      try await removeAllRepos()
      let l1Repo = l1.appending(component: "repoL1").path()
      let l2Repo = l2.appending(component: "repoL2").path()
      expectMatch(
         """
         The following 2 repos were added:
         • repoL1
         • repoL2
         """,
         try await gitty("l -a \(l1Repo) \(l2Repo)"),
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
   func `add Git repo path to the empty list verbosely`() async throws {
      try await removeAllRepos()
      let l1Repo = l1.appending(component: "repoL1").path()
      expectMatch(
         """
         The following repo was added:
         \("Repo: ".styles(.faint))\(l1Repo)/
         \("No tags.".styles(.faint))
         """,
         try await gitty("l -a \(l1Repo) -v"),
      )

      expectMatch(
         "• repoL1",
         try await gitty("l"),
      )
   }


   @Test
   func `add not Git repo path to the list`() async throws {
      expectMatch(
         "Path is not a Git repo: \(l1.path())",
         try await gitty("l -a \(l1.path())"),
      )
   }


   @Test
   func `add not existing path to the list`() async throws {
      let path = l1.appending(path: "gobbledygook").path()
      expectMatch(
         "Path does not exist: \(path)",
         try await gitty("l -a \(path)"),
      )
   }
}
