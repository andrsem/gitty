// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import ArgumentParser
import List
import Testing

@testable import gitty

@Suite(.tags(.gitty))
struct `Filtered List Tests` {
   let emptyList = List()
   let list = [Repo("~/abc"), Repo("~/xyz")]
   let listWithTag = [Repo("~/abc", ["tag1"]), Repo("~/xyz")]
   let listWithSameTag = [Repo("~/abc", ["tag1"]), Repo("~/xyz", ["tag1"])]


   @Test
   func `empty filtered list exits`() throws {
      #expect(throws: Never.self) {
         try emptyList.filtered(
            tags: [],
            includedPaths: [],
            excludedPaths: [],
            fixedString: false,
         )
      }
   }


   @Test
   func `filtered list by path not matching gives original list`() throws {
      let r = try list.filtered(
         tags: [],
         includedPaths: [],
         excludedPaths: [],
         fixedString: false,
      )
      #expect(r == list)
   }


   @Test(arguments: ["abc", "a.c"])
   func `filtered list matching path`(path: String) throws {
      let r = try list.filtered(
         tags: [],
         includedPaths: [path],
         excludedPaths: [],
         fixedString: false,
      )
      let e = [Repo("~/abc")]
      #expect(r == e)
   }


   @Test(arguments: ["~/abc", "~/abc/"])
   func `filtered list matching fixed string`(path: String) throws {
      let r = try list.filtered(
         tags: [],
         includedPaths: [path],
         excludedPaths: [],
         fixedString: true,
      )
      let e = [Repo("~/abc")]
      #expect(r == e)
   }


   @Test
   func `filtered list matching path excluding`() throws {
      let r = try list.filtered(
         tags: [],
         includedPaths: [],
         excludedPaths: ["abc"],
         fixedString: false,
      )
      let e = [Repo("~/xyz")]
      #expect(r == e)
   }


   @Test(arguments: ["~/abc", "~/abc/"])
   func `filtered list matching fixed string excluding`(path: String) throws {
      let r = try list.filtered(
         tags: [],
         includedPaths: [],
         excludedPaths: [path],
         fixedString: true,
      )
      let e = [Repo("~/xyz")]
      #expect(r == e)
   }


   @Test
   func `filtered using invalid regex`() throws {
      #expect(throws: InvalidRegex.self) {
         try list.filtered(
            tags: [],
            includedPaths: [],
            excludedPaths: ["(abc"],
            fixedString: false,
         )
      }
   }


   @Test
   func `filtered no matching path found`() throws {
      #expect(
         throws: CleanExit.message(FilterListError.noMatchingPath.description)
      ) {
         try list.filtered(
            tags: [],
            includedPaths: ["hello"],
            excludedPaths: [],
            fixedString: false,
         )
      }
   }


   @Test
   func `filtered tag does not exist`() throws {
      #expect(
         throws:
            CleanExit
            .message(
               FilterListError.tagsNotExist(["hello"], allTags: []).description
            )
      ) {
         try list.filtered(
            tags: ["hello"],
            includedPaths: [],
            excludedPaths: [],
            fixedString: false,
         )
      }
   }


   @Test
   func `filtered no repos without tags`() throws {
      #expect(
         throws:
            CleanExit.message(FilterListError.noUntaggedRepos.description)
      ) {
         try listWithSameTag.filtered(
            tags: ["none"],
            includedPaths: [],
            excludedPaths: [],
            fixedString: false,
         )
      }
   }


   @Test
   func `filtered by tag`() throws {
      let r = try listWithTag.filtered(
         tags: ["tag1"],
         includedPaths: [],
         excludedPaths: [],
         fixedString: false,
      )
      let e = [Repo("~/abc")]
      #expect(r == e)
   }


   @Test
   func `filtered by tag excluding`() throws {
      let r = try listWithTag.filtered(
         tags: ["!tag1"],
         includedPaths: [],
         excludedPaths: [],
         fixedString: false,
      )
      let e = [Repo("~/xyz")]
      #expect(r == e)
   }
}


// swift-format-ignore: AvoidRetroactiveConformances
extension CleanExit: @retroactive Equatable {
   static func == (
      lhs: ArgumentParser.CleanExit,
      rhs: ArgumentParser.CleanExit,
   ) -> Bool {
      lhs.description == rhs.description
   }
}
