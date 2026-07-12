// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import TTS
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eListSub))
struct `List Sub Remove E2E`: E2EConfigurable {
   // MARK: - gitty list [--remove <pattern>...] [--verbose]

   @Test
   func `removing from empty list`() async throws {
      try await removeAllRepos()
      _ = try await gitty("l -r repo")
      try await expectListIsEmpty(gitty, command: "l -r repo")
   }


   @Test
   func `removing specific path`() async throws {
      let path = l1.appending(component: "repoL1").path()
      expectMatch(
         """
         Do you want to remove the following repo:
         • repoL1

         Do you want to proceed? [y/[1mN[22m]
         The following repo was removed:
         • repoL1
         """,
         try await gitty("l -r \(path)", input: "y").trimmedEscapeCodes,
      )

      expectMatch(
         "• repoL2",
         try await gitty("l"),
      )
   }


   @Test
   func `removing using multiple regexes`() async throws {
      expectMatch(
         """
         Do you want to remove the following repos:
         • repoL1
         • repoL2

         Do you want to proceed? [y/[1mN[22m]
         The following 2 repos were removed:
         • repoL1
         • repoL2
         """,
         try await gitty("l -r '(?i)l1' 'L2'", input: "y").trimmedEscapeCodes,
      )

      try await expectListIsEmpty(gitty, command: "l")
   }


   @Test
   func `removing partially matching path`() async throws {
      expectMatch(
         """
         Do you want to remove the following repo:
         • repoL1

         Do you want to proceed? [y/[1mN[22m]
         The following repo was removed:
         • repoL1
         """,
         try await gitty("l -r repoL1", input: "y").trimmedEscapeCodes,
      )

      expectMatch(
         """
         Do you want to remove the following repo:
         • repoL2

         Do you want to proceed? [y/[1mN[22m]
         The following repo was removed:
         • repoL2
         """,
         try await gitty("l -r L2", input: "y").trimmedEscapeCodes,
      )

      try await expectListIsEmpty(gitty)
   }


   @Test
   func `removing all partially matching paths`() async throws {
      expectMatch(
         """
         Do you want to remove the following repos:
         • repoL1
         • repoL2

         Do you want to proceed? [y/[1mN[22m]
         The following 2 repos were removed:
         • repoL1
         • repoL2
         """,
         try await gitty("l -r repo", input: "y").trimmedEscapeCodes,
      )

      try await expectListIsEmpty(gitty)
   }


   @Test
   func `removing all partially matching paths verbosely`() async throws {
      expectMatch(
         """
         Do you want to remove the following repos:
         \("Repo: ".styles(.faint))\(l2.appending(component: "repoL2").path())/
         \("No tags.".styles(.faint))

         \("Repo: ".styles(.faint))\(l1.appending(component: "repoL1").path())/
         \("No tags.".styles(.faint))

         Do you want to proceed? [y/\("N".styles(.bold))]
         The following 2 repos were removed:
         \("Repo: ".styles(.faint))\(l2.appending(component: "repoL2").path())/
         \("No tags.".styles(.faint))

         \("Repo: ".styles(.faint))\(l1.appending(component: "repoL1").path())/
         \("No tags.".styles(.faint))
         """,
         try await gitty("l -r repo -v", input: "y"),
      )

      try await expectListIsEmpty(gitty)
   }


   @Test(arguments: ["REpO", "Ol"])
   func `removing all partially matching insensitive paths`(
      path: String
   ) async throws {
      expectMatch(
         """
         Do you want to remove the following repos:
         • repoL1
         • repoL2

         Do you want to proceed? [y/[1mN[22m]
         The following 2 repos were removed:
         • repoL1
         • repoL2
         """,
         try await gitty("l -r '(?i)\(path)'", input: "y").trimmedEscapeCodes,
      )

      try await expectListIsEmpty(gitty)
   }


   @Test
   func `removing with invalid regex`() async throws {
      _ = try await gitty("l -A \(l1.path())")

      expectMatch(
         "Error: Invalid path regex: expected ')'",
         try await gitty("l -r '(repo'").trimmedEscapeCodes,
      )

      expectMatch(
         "Error: Invalid path regex: quantifier '?' must appear after expression",
         try await gitty("l -r ?repo").trimmedEscapeCodes,
      )
   }
}
