// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import TTS
import Testing

@Suite(.serialized, .tags(.e2eAll, .e2eListSub))
struct `List Sub Add Tags E2E`: E2EConfigurable {
   // MARK: - gitty list [--add-tags <tags>...] [--include <pattern>...] [--exclude <pattern>...] [--verbose]

   @Test
   func `add tag matching repo`() async throws {
      expectMatch(
         """
         Tag added: \("cat".styles(.bold))
         At: repoL1
         """,
         try await gitty("l --add-tags cat -i repoL1"),
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
   func `add tag matching repo excluding`() async throws {
      expectMatch(
         """
         Tag added: \("cat".styles(.bold))
         At: repoL2
         """,
         try await gitty("l --add-tags cat -e repoL1"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2  \("cat".styles(.bold))
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `add tag verbosely`() async throws {
      expectMatch(
         """
         Tag added: \("cat".styles(.bold))
         At: \(l1.appending(path: "repoL1").path())/
         """,
         try await gitty("l --add-tags cat -i repoL1 --verbose"),
      )
   }


   @Test
   func `add tag to all repos`() async throws {
      expectMatch(
         """
         Tag added: \("cat".styles(.bold))
         At: repoL1
             repoL2
         """,
         try await gitty("l --add-tags cat"),
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
   func `add reserved tag none`() async throws {
      expectMatch(
         """
         Tag not added: \("none".styles(.bold))
         'none' is a reserved tag name to represent untagged repos.
         """,
         try await gitty("l --add-tags none -i repoL1"),
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
   func `add multiple tags`() async throws {
      expectMatch(
         """
         Tags added: \("cat".styles(.bold)) \("meow".styles(.bold))
         At: repoL1
         """,
         try await gitty("l --add-tags cat meow -i repoL1"),
      )

      expectMatch(
         """
         • repoL1  \("cat".styles(.bold)) \("meow".styles(.bold))
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `add multiple tags matching repo insensitive`() async throws {
      expectMatch(
         """
         Tags added: \("cat".styles(.bold)) \("meow".styles(.bold))
         At: repoL2
         """,
         try await gitty("l --add-tags cat meow -i '(?i)l2'"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2  \("cat".styles(.bold)) \("meow".styles(.bold))
         """,
         try await gitty("l"),
      )
   }


   @Test(arguments: ["l2", "l4", "repo1", "nonexisting/path"])
   func `paths not matching repoL1 or repoL2`(
      pathArgs: String
   ) async throws {
      expectMatch(
         "No repos matching the path.",
         try await gitty("l --add-tags tag1 tag2 -i \(pathArgs)"),
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
   func `add existing tag`() async throws {
      let tag = "cat"
      expectMatch(
         """
         Tag added: \(tag.styles(.bold))
         At: repoL1
         """,
         try await gitty("l --add-tags \(tag) -i repoL1"),
      )

      expectMatch(
         "Tag not added: \(tag.styles(.bold))",
         try await gitty("l --add-tags \(tag) -i repoL1"),
      )

      expectMatch(
         """
         • repoL1  \(tag.styles(.bold))
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test(arguments: [" ", "|", "&", "!", "(", ")"])
   func `add invalid tag`(illegalChar: Character) async throws {
      expectMatch(
         """
         Tags should not contain illegal characters like: whitespace, '|', '&', '!', '(', ')'
         '\("new\(illegalChar)cat".styles(.bold))'
         """,
         try await gitty("l --add-tags 'new\(illegalChar)cat' -i repoL1"),
      )

      expectMatch(
         """
         • repoL1
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test(arguments: [" ", "|", "&", "!", "(", ")"])
   func `add valid and invalid tags`(illegalChar: Character) async throws {
      expectMatch(
         """
         Tags should not contain illegal characters like: whitespace, '|', '&', '!', '(', ')'
         '\("new\(illegalChar)cat".styles(.bold))'
         """,
         try await gitty(
            "l --add-tags validCat 'new\(illegalChar)cat' -i repoL1"
         ),
      )

      expectMatch(
         """
         • repoL1
         • repoL2
         """,
         try await gitty("l"),
      )
   }
}
