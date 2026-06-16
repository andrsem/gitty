// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import SW40
import Testing

@testable import gitty

extension Tag {
   @Tag
   static var gitty: Self
}


@Suite(.tags(.gitty))
struct `Validator tests` {
   @Test(arguments: [0, 1, .max, nil])
   func `check valid depth`(depth: Int?) {
      #expect(throws: Never.self) { try Validator.checkDepth(depth) }
   }


   @Test(arguments: [-1, .min])
   func `check invalid depth`(depth: Int?) {
      #expect(throws: (any Error).self) { try Validator.checkDepth(depth) }
   }


   @Test(arguments: [["a"], ["abc", " g "], []])
   func `valid tags`(_ tags: [String]) throws {
      #expect(throws: Never.self) { try Validator.checkTags(tags) }
   }


   @Test(arguments: [["a a"], ["a bc", " g g"]])
   func `invalid tags`(_ tags: [String]) throws {
      #expect(throws: (any Error).self) { try Validator.checkTags(tags) }
   }


   static let validPaths = [["/", "~"], ["/bin"], ["~"]]

   @Test(arguments: validPaths)
   func `valid paths`(path: [String]) throws {
      #expect(throws: Never.self) { try Validator.checkPaths(path) }
   }


   @Test(arguments: validPaths)
   func `valid paths but not a git repo`(paths: [String]) throws {
      let message = paths.map { "Path is not a Git repo: \($0)" }
         .joined(separator: "\n")
      let error = CleanExit.message(message)
      #expect(throws: error.self) {
         try Validator.checkPaths(paths, wherePath: .isGit)
      }
   }


   @Test
   func `invalid path`() throws {
      let path = "/definitely-does-not-exist"
      let error = CleanExit.message("Path does not exist: \(path)")
      #expect(throws: error.self) {
         try Validator.checkPaths([path])
      }
   }


   @Test
   func `invalid path and not a git repo`() throws {
      let invalidPath = "/definitely-does-not-exist"
      let notGitRepo = "/"
      let error = CleanExit.message(
         """
         Path does not exist: \(invalidPath)
         Path is not a Git repo: \(notGitRepo)
         """
      )
      #expect(throws: error.self) {
         try Validator.checkPaths([notGitRepo, invalidPath], wherePath: .isGit)
      }
   }



   typealias ListActions = (
      [String], [String], [String], [String], [String], [String], [String]
   )

   @Test(arguments: [
      ListActions([], [], [], [], [], [], []),
      ListActions(["a"], [], [], [], [], [], []),
      ListActions([], ["a"], [], [], [], [], []),
      ListActions([], [], ["a"], [], [], [], []),
      ListActions([], [], [], ["a"], [], [], []),
      ListActions([], [], [], [], ["a"], [], []),
      ListActions([], [], [], [], [], ["a"], []),
      ListActions([], [], [], [], [], [], ["a"]),
   ])
   func `check valid list actions`(actions: ListActions) throws {
      #expect(throws: Never.self) {
         try actions |> Validator.checkListActions
      }
   }


   @Test(arguments: [
      ListActions(["a"], ["a"], [], [], [], [], []),
      ListActions(["a"], [], ["a"], [], [], [], []),
      ListActions(["a"], [], [], ["a"], [], [], []),
      ListActions(["a"], [], [], [], ["a"], [], []),
      ListActions(["a"], [], [], [], [], ["a"], []),
      ListActions(["a"], [], [], [], [], [], ["a"]),
      ListActions([], ["a"], ["a"], [], [], [], []),
      ListActions([], ["a"], [], ["a"], [], [], []),
      ListActions([], ["a"], [], [], ["a"], [], []),
      ListActions([], ["a"], [], [], [], ["a"], []),
      ListActions([], ["a"], [], [], [], [], ["a"]),
      ListActions([], [], ["a"], ["a"], [], [], []),
      ListActions([], [], ["a"], [], ["a"], [], []),
      ListActions([], [], ["a"], [], [], ["a"], []),
      ListActions([], [], ["a"], [], [], [], ["a"]),
      ListActions([], [], [], ["a"], ["a"], [], []),
      ListActions([], [], [], ["a"], [], ["a"], []),
      ListActions([], [], [], ["a"], [], [], ["a"]),
      ListActions([], [], [], [], ["a"], ["a"], []),
      ListActions([], [], [], [], ["a"], [], ["a"]),
      ListActions([], [], [], [], [], ["a"], ["a"]),
      ListActions(["a"], ["a"], ["a"], ["a"], ["a"], ["a"], ["a"]),
   ])
   func `check invalid list actions`(actions: ListActions) throws {
      #expect(throws: (any Error).self) {
         try actions |> Validator.checkListActions
      }
   }


   @Test
   func `check run missing args`() throws {
      #expect(throws: Never.self) {
         try Validator.checkRunMissingCommandArg(false)
      }

      #expect(throws: (any Error).self) {
         try Validator.checkRunMissingCommandArg(true)
      }
   }


   @Test(arguments: [0, 1, 255, 3_599_999, 3_600_000])
   func `check valid delay`(delay: Int) throws {
      #expect(throws: Never.self) {
         try Validator.checkDelay(delay)
      }
   }


   @Test(arguments: [Int.min, -1, 3_600_001, .max])
   func `check invalid delay`(delay: Int) throws {
      #expect(throws: (any Error).self) {
         try Validator.checkDelay(delay)
      }
   }
}
