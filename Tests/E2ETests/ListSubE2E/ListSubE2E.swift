// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import TTS
import Testing

extension Tag {
   @Tag
   static var e2eListSub: Self
}


@Suite(.serialized, .tags(.e2eAll, .e2eListSub))
struct `List Sub E2E`: E2EConfigurable {
   // MARK: - gitty list [--verbose]

   @Test
   func `after config initialization the list is empty'`() async throws {
      try await removeAllRepos()
      try await expectListIsEmpty(gitty)
   }


   @Test
   func `print list`() async throws {
      expectMatch(
         """
         • repoL1
         • repoL2
         """,
         try await gitty("l"),
      )
   }


   @Test
   func `list verbose`() async throws {
      expectMatch(
         """
         \("Repo: ".styles(.faint))\(l2.appending(component: "repoL2").path())/
         \("No tags.".styles(.faint))

         \("Repo: ".styles(.faint))\(l1.appending(component: "repoL1").path())/
         \("No tags.".styles(.faint))
         """,
         try await gitty("l -v"),
      )
   }


   // MARK: - gitty list [--include <pattern>...] [--exclude <pattern>...]

   @Test
   func `filter list by partial path`() async throws {
      expectMatch(
         "• repoL1",
         try await gitty("l -i '(?i)repol1'"),
      )
   }


   @Test
   func `filter list by full path`() async throws {
      let fullPath = l1.appending(component: "repoL1").path()
      expectMatch(
         "• repoL1",
         try await gitty("l -i \(fullPath)"),
      )
   }


   @Test
   func `filter list by partial path inverted`() async throws {
      expectMatch(
         "• repoL2",
         try await gitty("l -e '(?i)repol1'"),
      )
   }


   @Test(
      arguments: [
         "'(?i)repol1' -i '(?i)repol2'",
         "'(?i)repol1' '(?i)repol2'",
         "'(?i)repol[12]'",
      ]
   )
   func `filter list by multiple path regexes`(pattern: String) async throws {
      expectMatch(
         """
         • repoL1
         • repoL2
         """,
         try await gitty("l -i \(pattern)"),
      )
   }


   @Test
   func `filter list by partial path not found`() async throws {
      expectMatch(
         "No repos found for the matching path.",
         try await gitty("l -i somePath"),
      )
   }


   // MARK: - gitty list [--tags <expr>...] [--exclude] [--verbose]

   @Test
   func `filter list by tags`() async throws {
      try await addTags()
      expectMatch(
         "• repoL1  \("cat".styles(.bold))",
         try await gitty("l -t cat"),
      )
   }


   @Test
   func `filter list by excluded tags`() async throws {
      try await addTags()
      expectMatch(
         "• repoL2",
         try await gitty("l -t '!cat'"),
      )
   }


   @Test
   func `filter list by tags with complex logical expression`() async throws {
      try await addTags()
      _ = try await gitty("l --add-tags ab -i repoL2")
      _ = try await gitty("l -A \(l1.path()) -d 5")
      expectMatch(
         """
         • repoL2  \("ab".styles(.bold))
         • repoOtherL4
         """,
         try await gitty("l -t '!cat & (ab|none)'"),
      )
   }


   @Test
   func `filter list by repos without tags`() async throws {
      try await addTags()
      expectMatch(
         "• repoL2",
         try await gitty("l -t none"),
      )
   }


   @Test
   func `filter list by tags verbose`() async throws {
      _ = try await gitty("l --add-tags xy ab -i repoL1")
      expectMatch(
         """
         Available tags: \("ab".styles(.bold)) \("xy".styles(.bold))

         \("Repo: ".styles(.faint))\(l2.appending(component: "repoL2").path())/
         \("No tags.".styles(.faint))

         \("Repo: ".styles(.faint))\(l1.appending(component: "repoL1").path())/
         \("Tags: ".styles(.faint))\("ab".styles(.bold)) \("xy".styles(.bold))
         """,
         try await gitty("l -v"),
      )
   }


   @Test
   func `filter list no repos without tags`() async throws {
      try await addTags(toAll: true)

      expectMatch(
         "No untagged repos.",
         try await gitty("l -t none"),
      )
   }


   @Test
   func `filter list by tag not found`() async throws {
      expectMatch(
         """
         No repos with tag: [1mnotATag[22m
         No tags available.

         To add tags to an existing repo, use:
           'gitty list --add-tags tag1 tag2 --include <pattern>'

           See 'gitty list --help' for more information.
         """,
         try await gitty("l -t notATag").trimmedEscapeCodes,
      )
   }



   @Test
   func `filter list by tag no repo found`() async throws {
      try await addTags()
      expectMatch(
         """
         No repos with tags: [1mnotATag[22m [1mnotATag2[22m
         Available tag: [1mcat[22m

         To add tags to an existing repo, use:
           'gitty list --add-tags tag1 tag2 --include <pattern>'

           See 'gitty list --help' for more information.
         """,
         try await gitty("l -t 'notATag | notATag2'").trimmedEscapeCodes,
      )
   }
}
