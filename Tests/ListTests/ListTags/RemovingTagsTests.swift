// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Testing

@testable import List

extension `List Tests` {
   @Suite
   struct `Removing tags` {
      @Test
      func `removing tags form all repos`() throws {
         let d1 = try emptyList.removingTags([], includedPaths: [])
         #expect(d1.list.allTags == emptyList.allTags)
         expectMatch(d1.message, ListMessage.noReposWithPath)

         let d2 = try emptyList.removingTags(["Abc"], includedPaths: [])
         #expect(d2.list.allTags == emptyList.allTags)
         expectMatch(d2.message, ListMessage.noReposWithPath)

         let d3 = try cleanList.removingTags([], includedPaths: [])
         #expect(d3.list.allTags == cleanList.allTags)
         expectMatch(
            d3.message,
            ListMessage.tagsRemoved([], excluded: [], repos: [])
         )

         let d5 = try cleanList.removingTags(["d3"], includedPaths: [])
         #expect(d5.list.allTags == [])
         expectMatch(
            d5.message,
            ListMessage.tagsRemoved(["d3"], excluded: [], repos: [ListTests.d3])
         )

         let r1 = Repo("~", ["z", "d", "a", "b"])
         let d6 = try [r1].removingTags(["d", "b", "xyz"], includedPaths: [])
         #expect(d6.list.allTags == ["a", "z"])
         expectMatch(
            d6.message,
            ListMessage.tagsRemoved(["b", "d"], excluded: ["xyz"], repos: [r1])
         )

         let r2 = Repo("~/abc", ["z", "g", "a", "b"])
         let r3 = Repo("~/xyz", ["z", "d", "xyz", "a", "b"])
         let d7 = try [r1, r2, r3]
            .removingTags(["d", "b", "xyz"], includedPaths: [])
         #expect(d7.list[0].tags == ["a", "z"])
         #expect(d7.list[1].tags == ["a", "g", "z"])
         #expect(d7.list[2].tags == ["a", "z"])
         expectMatch(
            d7.message,
            ListMessage.tagsRemoved(
               ["b", "d", "xyz"],
               excluded: [],
               repos: [r1, r2, r3]
            )
         )
      }


      @Test
      func `removing tags with edge spaces`() throws {
         let d1 = try cleanList.removingTags(["  d3  "], includedPaths: [])
         #expect(d1.list.allTags == [])
         expectMatch(
            d1.message,
            ListMessage.tagsRemoved(["d3"], excluded: [], repos: [d3])
         )
      }


      @Test
      func `removing tags from concrete repo`() throws {
         let d1 = try emptyList.removingTags(
            [],
            includedPaths: ["~/CatPictures"]
         )
         #expect(d1.list.allTags == emptyList.allTags)
         expectMatch(d1.message, ListMessage.noReposWithPath)

         let d2 = try emptyList.removingTags(
            ["Abc"],
            includedPaths: ["~/CatPictures"]
         )
         #expect(d2.list.allTags == emptyList.allTags)
         expectMatch(d2.message, ListMessage.noReposWithPath)

         let d3 = try cleanList.removingTags(
            [],
            includedPaths: ["~/CatPictures"]
         )
         #expect(d3.list.allTags == cleanList.allTags)
         expectMatch(d3.message, ListMessage.noReposWithPath)

         let d4 = try cleanList.removingTags([], includedPaths: ["~/Developer"])
         #expect(d4.list.allTags == cleanList.allTags)
         expectMatch(
            d4.message,
            ListMessage.tagsRemoved([], excluded: [], repos: [])
         )

         let d5 = try cleanList.removingTags(
            ["d3"],
            includedPaths: ["~/Developer"]
         )
         #expect(d5.list.allTags == [])
         expectMatch(
            d5.message,
            ListMessage.tagsRemoved(["d3"], excluded: [], repos: [ListTests.d3])
         )

         let repoWithTags = Repo("~", ["z", "d", "a", "b"])
         let d6 = try [repoWithTags]
            .removingTags(["d", "b", "xyz"], includedPaths: ["~"])
         #expect(d6.list.allTags == ["a", "z"])
         expectMatch(
            d6.message,
            ListMessage.tagsRemoved(
               ["b", "d"],
               excluded: ["xyz"],
               repos: [repoWithTags]
            )
         )
      }


      @Test
      func `removing tags from repos matching the pattern`() throws {
         let r1 = Repo("~/repo1", ["a", "b"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", [])

         let d1 = try [r1, r2, r3].removingTags(["b"], includedPaths: ["repo"])
         #expect(d1.list[0].tags == ["a"])
         #expect(d1.list[1].tags == [])
         #expect(d1.list[2].tags == [])
         expectMatch(
            d1.message,
            ListMessage.tagsRemoved(["b"], excluded: [], repos: [r1, r2])
         )

         let d2 = try [r1, r2, r3].removingTags(["b"], includedPaths: ["po2"])
         #expect(d2.list[0].tags == ["a", "b"])
         #expect(d2.list[1].tags == [])
         #expect(d2.list[2].tags == [])
         expectMatch(
            d2.message,
            ListMessage.tagsRemoved(["b"], excluded: [], repos: [r2])
         )

         let d3 = try [r1, r2, r3]
            .removingTags(["a", "b", "c"], includedPaths: ["re"])
         #expect(d3.list[0].tags == [])
         #expect(d3.list[1].tags == [])
         #expect(d3.list[2].tags == [])
         expectMatch(
            d3.message,
            ListMessage.tagsRemoved(
               ["a", "b"],
               excluded: ["c"],
               repos: [r1, r2]
            )
         )
      }


      @Test
      func `removing tags from repos matching the pattern excluding`() throws {
         let r1 = Repo("~/repo1", ["a", "b"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", [])

         let d1 = try [r1, r2, r3]
            .removingTags(["b"], includedPaths: [], excludedPaths: ["repo"])
         #expect(d1.list[0].tags == ["a", "b"])
         #expect(d1.list[1].tags == ["b"])
         #expect(d1.list[2].tags == [])
         expectMatch(d1.message, ListMessage.noReposWithPath)

         let d2 = try [r1, r2, r3]
            .removingTags(["b"], includedPaths: [], excludedPaths: ["po2"])
         #expect(d2.list[0].tags == ["a"])
         #expect(d2.list[1].tags == ["b"])
         #expect(d2.list[2].tags == [])
         expectMatch(
            d2.message,
            ListMessage.tagsRemoved(["b"], excluded: [], repos: [r1])
         )

         let d3 = try [r1, r2, r3]
            .removingTags(
               ["a", "b", "c"],
               includedPaths: [],
               excludedPaths: ["repo1"]
            )
         #expect(d3.list[0].tags == ["a", "b"])
         #expect(d3.list[1].tags == [])
         #expect(d3.list[2].tags == [])
         expectMatch(
            d3.message,
            ListMessage.tagsRemoved(["b"], excluded: ["a", "c"], repos: [r2])
         )
      }


      @Test
      func `removing tags with insensitive case and diacritic match`() throws {
         let r1 = Repo("~/repo1", ["a", "b"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", [])

         let d1 = try [r1, r2, r3].removingTags(["b"], includedPaths: ["Repo"])
         #expect(d1.list.allTags == ["a", "b", "b"])
         expectMatch(d1.message, ListMessage.noReposWithPath)

         let d2 = try [r1, r2, r3]
            .removingTags(["b"], includedPaths: ["(?i)Repo"])
         #expect(d2.list[0].tags == ["a"])
         #expect(d2.list[1].tags == [])
         #expect(d2.list[2].tags == [])
         expectMatch(
            d2.message,
            ListMessage.tagsRemoved(["b"], excluded: [], repos: [r1, r2])
         )
      }
   }
}
