// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Shared
import TTS
import Testing

extension Tag {
   @Tag
   static var e2eRunSub: Self
}

@Suite(.serialized, .tags(.e2eAll, .e2eRunSub))
struct `Run Sub E2E`: E2EConfigurable {
   // MARK: - gitty run <alias/command> [--parallel] [--quiet] [--compact]

   @Test
   func `run alias fetch sorted az`() async throws {
      expectMatch(
         """
         # gitty.repo repoL1
         # gitty.repo repoL2
         """,
         try await gitty("r 'fetch' --sort az"),
      )
   }


   @Test
   func `specified sort overrides alias sort`() async throws {
      expectMatch(
         """
         # gitty.repo repoL2
         # gitty.repo repoL1
         """,
         try await gitty("r 'fetch' --sort za"),
      )
   }


   @Test
   func `gitty can't run commands on empty list`() async throws {
      try await removeAllRepos()
      let out = try await gitty("r ls", input: "y")
      #expect(out.contains("The list is empty."))
      #expect(out.contains("Add Git repos to the list:"))
   }


   @Test
   func `gitty can't run aliases on empty list`() async throws {
      try await removeAllRepos()
      let out = try await gitty("r fetch")
      #expect(out.contains("The list is empty."))
      #expect(out.contains("Add Git repos to the list:"))
   }


   @Test
   func `run on repos`() async throws {
      expectMatch(
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         # gitty.repo repoL1
         fileL1
         otherFileL1

         # gitty.repo repoL2
         fileL2
         otherFileL2

         """,
         try await gitty("r ls --sort az", input: "y"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run on repos quietly`() async throws {
      expectMatch(
         """
         # gitty.repo repoL1
         fileL1
         otherFileL1

         # gitty.repo repoL2
         fileL2
         otherFileL2

         """,
         try await gitty("r ls --sort az --quiet", input: "y"),
      )
   }


   @Test
   func `run on repos compact`() async throws {
      expectMatch(
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         fileL1
         otherFileL1
         fileL2
         otherFileL2
         """,
         try await gitty("r ls --sort az --compact", input: "y"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run command to print spaces and new lines`() async throws {
      expectMatch(
         """
         # gitty.repo repoL1


         abc


         # gitty.repo repoL2


         abc


         """,
         try await gitty(#"r "printf '\n\nabc\n\n'" --quiet"#, input: "y"),
         trimLineEnds: false,
      )
   }


   @Test(arguments: ["az", "za", "unsorted"])
   func `run command to print spaces and new lines compact`(
      sort: String
   ) async throws {
      expectMatch(
         """


         abc



         abc

         """,
         try await gitty(
            #"r "printf '\n\nabc\n\n'" --quiet --compact --sort \#(sort)"#,
            input: "y",
         ),
         trimLineEnds: false,
      )
   }


   @Test
   func `run on repos in parallel`() async throws {
      let title =
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         """

      let repos1 =
         """

         # gitty.repo repoL1
         fileL1
         otherFileL1

         # gitty.repo repoL2
         fileL2
         otherFileL2
         """

      let repos2 =
         """

         # gitty.repo repoL2
         fileL2
         otherFileL2

         # gitty.repo repoL1
         fileL1
         otherFileL1
         """

      let variants = [(title + repos1), (title + repos2)]
         .map(\.trimmedWN)

      let result =
         try await gitty("r ls --parallel", input: "y").trimmedWN

      #expect(variants.contains(result))
   }


   // MARK: - gitty run <alias/command> [--tags <expr>...] [--exclude]

   @Test
   func `run on repos with tags`() async throws {
      try await addTags()

      expectMatch(
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         # gitty.repo repoL1
         fileL1
         otherFileL1

         """,
         try await gitty("r ls --sort az --tags cat", input: "y"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run on repos excluding tags`() async throws {
      try await addTags()

      expectMatch(
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         # gitty.repo repoL2
         fileL2
         otherFileL2

         """,
         try await gitty("r ls --sort az  --tags '!cat'", input: "y"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run on repos without tags`() async throws {
      try await addTags()

      expectMatch(
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         # gitty.repo repoL2
         fileL2
         otherFileL2

         """,
         try await gitty("r ls --sort az --tags none", input: "y"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run on repos with not existing tags`() async throws {
      try await addTags()

      expectMatch(
         """
         No repos with tag: [1mgobbledygook[22m
         Available tag: [1mcat[22m

         To add tags to an existing repo, use:
           'gitty list --add-tags tag1 tag2 --include <pattern>'

           See 'gitty list --help' for more information.
         """,
         try await gitty("r ls --tags gobbledygook", input: "y")
            .trimmedEscapeCodes,
         trimLineEnds: true,
      )
   }


   // MARK: - gitty run <alias/command> [--include <pattern>...] [--exclude <pattern>...]

   @Test
   func `run on repos matching path`() async throws {
      expectMatch(
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         # gitty.repo repoL1
         fileL1
         otherFileL1

         """,
         try await gitty("r ls --sort az --include repoL1", input: "y"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run on repos matching path excluding`() async throws {
      expectMatch(
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         # gitty.repo repoL2
         fileL2
         otherFileL2

         """,
         try await gitty("r ls --sort az --exclude repoL1", input: "y"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run on repos when command fails for some repos`() async throws {
      let command =
         "ls | grep -q 'fileL2' && { echo 'Error: ls contains fileL2' >&2; exit 1; } || ls"
      expectMatch(
         """
         # gitty.repo repoL1
         fileL1
         otherFileL1

         # gitty.repo repoL2
         # gitty.repo repoL2 Error: ls contains fileL2

         """,
         try await gitty("r \"\(command)\" --sort az -q"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run on repos when command fails for some repos compact`() async throws
   {
      let command =
         "ls | grep -q 'fileL2' && { echo 'Error: ls contains fileL2' >&2; exit 1; } || ls"
      expectMatch(
         """
         # gitty.repo repoL2 Error: ls contains fileL2
         fileL1
         otherFileL1
         """,
         try await gitty("r \"\(command)\" --sort az -q --compact"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run on repos no matching path found`() async throws {
      expectMatch(
         """
         No repos found for the matching path.
         """,
         try await gitty("r ls --sort az --include gobbledygook", input: "y"),
         trimLineEnds: true,
      )
   }



   // MARK: - gitty run <alias/command> [--status <expr>...]

   @Test
   func `run on repos matching invalid filter`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 6")

      let r = try await gitty("r ls --status gobbledygook -q", input: "y")
      let e =
         """
         The value 'gobbledygook' is invalid for '--status <expr>'. Please provide one of 'added', 'clean', 'copied', 'deleted', 'detached', 'ignored', 'initial-commit', 'locked', 'modified', 'needs-pull', 'needs-push', 'needs-upstream', 'renamed', 'submodule', 'sub-commit-change', 'sub-modified', 'sub-untracked', 'type-change', 'unmerged', 'untracked'.
         Help:  --status <expr>  Filter repos by status using logical expressions.
         """
      #expect(r.contains(e))
   }


   @Test
   func `run on repos matching valid filter`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 6")

      expectMatch(
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         # gitty.repo repoL1
         fileL1
         otherFileL1

         """,
         try await gitty("r ls --sort az --status added", input: "y"),
         trimLineEnds: true,
      )
   }


   @Test
   func `run on repos matching valid filter excluding`() async throws {
      _ = try await gitty("l -A \(l1.path()) -d 6")

      expectMatch(
         """
         COMMAND will be executed:

         ls

         Do you want to proceed? [y/\("N".styles(.bold))]

         # gitty.repo   repo with spaces
         # gitty.repo repoL2
         fileL2
         otherFileL2

         # gitty.repo repoOtherL4
         fileOtherL4
         otherFileOtherL4

         """,
         try await gitty("r ls --sort az --status '!added'", input: "y"),
         trimLineEnds: true,
      )
   }
}
