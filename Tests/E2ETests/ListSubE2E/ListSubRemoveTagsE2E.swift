// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import TTS
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eListSub))
struct `List Sub Remove Tags E2E`: E2EConfigurable {
   // MARK: - gitty list [--remove-tags <expr>...] [--include <pattern>...] [--exclude <pattern>...] [--verbose]

   @Test
   func `remove tag from repo`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await gitty("l --add-tags cat")

      expectMatch(
         """
         Tag removed: \("cat".styles(.bold))
         At: repoL1
         """,
         try await gitty("l --remove-tags cat -i repoL1"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2  \("cat".styles(.bold))
         • repoOtherL4  \("cat".styles(.bold))
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `remove tag from repo verbose`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await gitty("l --add-tags cat")

      expectMatch(
         """
         Tag removed: \("cat".styles(.bold))
         At: \(l1.appending(path: "repoL1").path())/
         """,
         try await gitty("l --remove-tags cat -i repoL1 -v"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2  \("cat".styles(.bold))
         • repoOtherL4  \("cat".styles(.bold))
         """,
         try await gitty("l"),
      )
   }



   @Test
   func `remove tag from repo not matching path`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await gitty("l --add-tags cat")

      expectMatch(
         "No repos matching the path.",
         try await gitty("l --remove-tags cat -i gobbledygook"),
      )

      expectMatch(
         """
         • repoL1  \("cat".styles(.bold))
         • repoL2  \("cat".styles(.bold))
         • repoOtherL4  \("cat".styles(.bold))
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `remove tag from repos matching path`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await gitty("l --add-tags cat")

      expectMatch(
         """
         Tag removed: \("cat".styles(.bold))
         At: repoL1
             repoL2
         """,
         try await gitty("l --remove-tags cat -i repoL"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2
         • repoOtherL4  \("cat".styles(.bold))
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `remove tag from repos matching path excluding`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await gitty("l --add-tags cat")

      expectMatch(
         """
         Tag removed: \("cat".styles(.bold))
         At: repoOtherL4
         """,
         try await gitty("l --remove-tags cat -e repoL"),
      )

      expectMatch(
         """
         • repoL1  \("cat".styles(.bold))
         • repoL2  \("cat".styles(.bold))
         • repoOtherL4
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `remove tag from all repos`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await gitty("l --add-tags cat")

      expectMatch(
         """
         Tag removed: \("cat".styles(.bold))
         At: repoL1
             repoL2
             repoOtherL4
         """,
         try await gitty("l --remove-tags cat"),
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


   @Test
   func `remove multiple tags`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await gitty("l --add-tags meow cat")

      expectMatch(
         """
         Tags removed: \("cat".styles(.bold)) \("meow".styles(.bold))
         At: repoL1
             repoL2
             repoOtherL4
         """,
         try await gitty("l --remove-tags meow cat"),
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


   @Test
   func `remove non existing tag`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await addTags()

      expectMatch(
         "Tag not removed: \("hello".styles(.bold))",
         try await gitty("l --remove-tags hello"),
      )

      expectMatch(
         """
         • repoL1  \("cat".styles(.bold))
         • repoL2
         • repoOtherL4
         """,
         try await gitty("l"),
      )
   }


   @Test(arguments: [" ", "|", "&", "!", "(", ")"])
   func `remove existing, non existing and invalid tags`(
      illegalChar: Character
   ) async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await addTags()

      expectMatch(
         """
         Tags should not contain illegal characters like: whitespace, '|', '&', '!', '(', ')'
         '\("hello\(illegalChar)there".styles(.bold))'
         """,
         try await gitty("l --remove-tags 'hello\(illegalChar)there' cat bye"),
      )

      expectMatch(
         """
         • repoL1  [1mcat[22m
         • repoL2
         • repoOtherL4
         """,
         try await gitty("l").trimmedEscapeCodes,
      )
   }


   @Test
   func `remove reserved tag`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 5")
      _ = try await addTags()

      expectMatch(
         """
         Tag not removed: \("none".styles(.bold))
         'none' is a reserved tag name to represent untagged repos.
         """,
         try await gitty("l --remove-tags none"),
      )

      expectMatch(
         """
         • repoL1  [1mcat[22m
         • repoL2
         • repoOtherL4
         """,
         try await gitty("l").trimmedEscapeCodes,
      )
   }
}
