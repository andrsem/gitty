// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Testing

extension Tag {
   @Tag
   static var e2eStatusSub: Self
}

@Suite(.serialized, .tags(.e2eAll, .e2eStatusSub))
struct `Status Sub E2E`: E2EConfigurable {
   // MARK: - gitty status

   @Test
   func `status for empty list`() async throws {
      try await removeAllRepos()
      try await expectListIsEmpty(gitty, command: "s")
   }


   @Test
   func `status for items in the list`() async throws {
      expectMatch(
         """
           [38;5;214mA[39m  [31m?[39m repoL1                   [35m⇞[39m[1mmain      [22m    
              [31m?[39m repoL2                   [35m⇞[39m[1mmain      [22m    
         """,
         try await gitty("s").trimmedEscapeCodes
      )
   }


   // MARK: - gitty status [--include <pattern>...] [--exclude <pattern>...]

   @Test
   func `status for repos filtered by path not found`() async throws {
      expectMatch(
         "No repos found for the matching path.",
         try await gitty("s -i gobbledygook")
      )
   }


   @Test
   func `status for repos filtered by path`() async throws {
      expectMatch(
         "[31m*[39m repoL1 [35m⇞[39m ",
         try await gitty("s -i '(?i)repol1' -l mini").trimmedEscapeCodes
      )
   }


   @Test
   func `status for repos filtered by path excluding`() async throws {
      expectMatch(
         "[31m*[39m repoL2 [35m⇞[39m ",
         try await gitty("s -e '(?i)repol1' -l mini").trimmedEscapeCodes
      )
   }


   // MARK: - gitty status [--tags <expr>...] [--exclude]

   @Test
   func `status for repos filtered by tags`() async throws {
      try await addTags()
      expectMatch(
         "[31m*[39m repoL1 [35m⇞[39m ",
         try await gitty("s -t cat -l mini").trimmedEscapeCodes
      )
   }


   @Test
   func `status for repos filtered by excluded tags`() async throws {
      try await addTags()
      expectMatch(
         "[31m*[39m repoL2 [35m⇞[39m ",
         try await gitty("s -t '!cat' -l mini").trimmedEscapeCodes
      )
   }


   @Test
   func `status for repos filtered by repos without tags`() async throws {
      try await addTags()
      expectMatch(
         "[31m*[39m repoL2 [35m⇞[39m ",
         try await gitty("s -t none -l mini").trimmedEscapeCodes
      )
   }


   @Test
   func
      `status for repos filtered by repos without tags where there are no such`()
      async throws
   {
      try await addTags(toAll: true)
      expectMatch(
         "No untagged repos.",
         try await gitty("s -t none -l mini").trimmedEscapeCodes
      )
   }


   @Test
   func `status for repos without tags using non existing tag`() async throws {
      expectMatch(
         """
         No repos with tag: [1mcat[22m
         No tags available.

         To add tags to an existing repo, use:
           'gitty list --add-tags tag1 tag2 --include <pattern>'

           See 'gitty list --help' for more information.
         """,
         try await gitty("s -t cat").trimmedEscapeCodes
      )
   }


   @Test
   func `status for repos with tag using non existing tag`() async throws {
      try await addTags()
      expectMatch(
         """
         No repos with tag: [1mhello[22m
         Available tag: [1mcat[22m

         To add tags to an existing repo, use:
           'gitty list --add-tags tag1 tag2 --include <pattern>'

           See 'gitty list --help' for more information.
         """,
         try await gitty("s -t hello").trimmedEscapeCodes
      )
   }


   @Test
   func `status for repos with multiple tags using non existing tags`()
      async throws
   {
      _ = try await gitty("l --add-tags cat dog -i repoL1")

      expectMatch(
         """
         No repos with tags: [1mhello[22m [1mbye[22m
         Available tags: [1mcat[22m [1mdog[22m

         To add tags to an existing repo, use:
           'gitty list --add-tags tag1 tag2 --include <pattern>'

           See 'gitty list --help' for more information.
         """,
         try await gitty("s -t 'hello|bye'").trimmedEscapeCodes
      )
   }


   @Test
   func `status for repos with tags using non existing and existing tags`()
      async throws
   {
      _ = try await gitty("l --add-tags cat dog -i repoL1")

      expectMatch(
         """
         No repos with tag: [1mhello[22m
         Available tags: [1mcat[22m [1mdog[22m

         To add tags to an existing repo, use:
           'gitty list --add-tags tag1 tag2 --include <pattern>'

           See 'gitty list --help' for more information.
         """,
         try await gitty("s -t 'hello | dog' -l mini").trimmedEscapeCodes
      )
   }


   // MARK: - gitty status [--layout <name>]

   @Test
   func `status with mini layout`() async throws {
      expectMatch(
         """
         [31m*[39m repoL1 [35m⇞[39m 
         [31m*[39m repoL2 [35m⇞[39m 
         """,
         try await gitty("s -l mini").trimmedEscapeCodes
      )
   }


   @Test
   func `status with non existing layout`() async throws {
      expectMatch(
         "Error: 'notALayout' layout doesn't exist.",
         try await gitty("s -l notALayout").trimmedEscapeCodes
      )
   }


   @Test
   func `status for repo with spaces in the name`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 6")
      expectMatch(
         """
         [1m[32m✓[39m[22m   repo with spaces   [35m⇞[39m 
         [31m*[39m repoL1 [35m⇞[39m 
         [31m*[39m repoL2 [35m⇞[39m 
         [31m*[39m repoOtherL4 [35m⇞[39m 
         """,
         try await gitty("s -l mini").trimmedEscapeCodes
      )
   }


   @Test
   func `status for repo with errors`() async throws {
      try Data().write(to: l1.appending(path: "repoL1/.git/index"))
      expectMatch(
         """
         \(l1.appending(path: "repoL1").path())/
         fatal: .git/index: index file smaller than expected

         [31m*[39m repoL2 [35m⇞[39m 
         """,
         try await gitty("s -l mini").trimmedEscapeCodes
      )
   }
}
