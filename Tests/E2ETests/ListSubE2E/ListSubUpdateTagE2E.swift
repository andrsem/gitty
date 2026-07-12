// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import TTS
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eListSub))
struct `List Sub Update Tag E2E`: E2EConfigurable {
   // MARK: - gitty list [--retag <old> <new>] [--include <pattern>...] [--exclude <pattern>...] [--verbose]

   @Test
   func `update non existing tag`() async throws {
      _ = try await gitty("l --add-tags cat -i repoL1")

      expectMatch(
         """
         Tag not updated
         from: \("absentCat".styles(.bold))
           to: \("newcat".styles(.bold))
         """,
         try await gitty("l --retag absentCat newcat"),
      )

      expectMatch(
         """
         • repoL1  \("cat".styles(.bold))
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test(arguments: [" ", "|", "&", "!", "(", ")"])
   func `update existing invalid tag`(illegalChar: Character) async throws {
      _ = try await gitty("l --add-tags cat -i repoL1")

      expectMatch(
         """
         Tags should not contain illegal characters like: whitespace, '|', '&', '!', '(', ')'
         '\("new\(illegalChar)cat".styles(.bold))'
         """,
         try await gitty("l --retag cat 'new\(illegalChar)cat'"),
      )

      expectMatch(
         """
         • repoL1  \("cat".styles(.bold))
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `update existing tag with reserved tag`() async throws {
      _ = try await gitty("l --add-tags cat -i repoL1")

      expectMatch(
         """
         Tag not updated
         from: \("cat".styles(.bold))
           to: \("none".styles(.bold))
         'none' is a reserved tag name to represent untagged repos.
         """,
         try await gitty("l --retag cat none"),
      )

      expectMatch(
         """
         • repoL1  \("cat".styles(.bold))
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `update tag on all repos`() async throws {
      _ = try await gitty("l --add-tags cat")

      expectMatch(
         """
         Tag updated
         from: \("cat".styles(.bold))
           to: \("newcat".styles(.bold))

         At: repoL1
             repoL2
         """,
         try await gitty("l --retag cat newcat"),
      )

      expectMatch(
         """
         • repoL1  \("newcat".styles(.bold))
         • repoL2  \("newcat".styles(.bold))
         """,
         try await gitty("l"),
      )
   }


   @Test(arguments: ["a", "a b c"])
   func `update tag old and new tag names should be provided`(
      tags: String
   ) async throws {
      _ = try await gitty("l --add-tags cat")

      expectMatch(
         """
         Error: Expecting 2 arguments for '--retag <old> <new>'
         Help:  --retag <old> <new>  Rename tag from <old> to <new>.
           See 'gitty list --help' for more information.
         """,
         try await gitty("l --retag \(tags)"),
      )

      expectMatch(
         """
         • repoL1  \("cat".styles(.bold))
         • repoL2  \("cat".styles(.bold))
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `update tag matching path`() async throws {
      _ = try await gitty("l --add-tags cat -i repoL1")

      expectMatch(
         """
         Tag updated
         from: \("cat".styles(.bold))
           to: \("newcat".styles(.bold))

         At: repoL1
         """,
         try await gitty("l --retag cat newcat"),
      )

      expectMatch(
         """
         • repoL1  \("newcat".styles(.bold))
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `update tag matching path excluding`() async throws {
      _ = try await gitty("l --add-tags cat -e repoL1")

      expectMatch(
         """
         Tag updated
         from: \("cat".styles(.bold))
           to: \("newcat".styles(.bold))

         At: repoL2
         """,
         try await gitty("l --retag cat newcat"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2  \("newcat".styles(.bold))
         """,
         try await gitty("l"),
      )
   }
}
