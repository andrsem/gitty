// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Shared
import Testing

@testable import List

extension `List Tests` {
   @Suite
   struct `Adding tags` {
      @Test
      func `adding tags to all repos`() throws {
         let r1 = Repo("~/repo1", ["a", "b"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", [])

         let a1 = try [r1, r2, r3].addingTags(["a"], includedPaths: [])
         #expect(a1.list[0].tags == ["a", "b"])
         #expect(a1.list[1].tags == ["a", "b"])
         #expect(a1.list[2].tags == ["a"])
         expectMatch(
            a1.message,
            ListMessage.tagsAdded(["a"], excluded: [], repos: [r2, r3])
         )

         let a2 = try [r1, r2].addingTags(["b", "c"], includedPaths: [])
         #expect(a2.list[0].tags == ["a", "b", "c"])
         #expect(a2.list[1].tags == ["b", "c"])
         expectMatch(
            a2.message,
            ListMessage.tagsAdded(["c"], excluded: ["b"], repos: [r1, r2])
         )
      }


      @Test
      func `adding tag with edge spaces`() throws {
         let r1 = Repo("~/repo1", ["a", "b"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", [])

         let a1 = try [r1, r2, r3].addingTags(["  a   "], includedPaths: [])
         #expect(a1.list[0].tags == ["a", "b"])
         #expect(a1.list[1].tags == ["a", "b"])
         #expect(a1.list[2].tags == ["a"])
         expectMatch(
            a1.message,
            ListMessage.tagsAdded(["a"], excluded: [], repos: [r2, r3])
         )
      }


      @Test
      func `adding reserved tag 'none'`() throws {
         let r1 = Repo("~/repo1", ["a", "b"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", [])

         let a1 = try [r1, r2, r3].addingTags(["none"], includedPaths: [])
         #expect(a1.list[0].tags == r1.tags)
         #expect(a1.list[1].tags == r2.tags)
         #expect(a1.list[2].tags == r3.tags)
         expectMatch(
            a1.message,
            ListMessage.tagsAdded([], excluded: ["none"], repos: [])
         )
      }


      @Test
      func `adding tags with whitespace`() throws {
         let r3 = Repo("~/repo3", [])

         let aEmpty = try [r3].addingTags(["", " "], includedPaths: [])
         #expect(aEmpty.list[0].tags == [])
         expectMatch(
            aEmpty.message,
            ListMessage.tagsAdded([], excluded: [""], repos: [])
         )

         let spacesAround = [
            "  g ",
            """

               abc

            """,
         ]
         let aWhitespace = try [r3].addingTags(spacesAround, includedPaths: [])
         #expect(aWhitespace.list[0].tags == ["abc", "g"])
         expectMatch(
            aWhitespace.message,
            ListMessage.tagsAdded(["abc", "g"], excluded: [], repos: [r3])
         )


         let insideSpaces = [
            "a\na",
            "a\ta",
            "a\ra",
            "  g g ",
            """

            a b c

            """,
         ]
         let withWhitespace = try [r3]
            .addingTags(insideSpaces, includedPaths: [])
         #expect(withWhitespace.list[0].tags == [])
         let e2 = ListMessage.tagsAdded(
            [],
            excluded:
               insideSpaces
               .map(\.trimmedWN)
               .sorted(),
            repos: []
         )
         #expect(withWhitespace.message == e2)
      }


      @Test
      func `adding tags to concrete repo`() throws {
         let a1 = try emptyList.addingTags([], includedPaths: ["~/CatPictures"])
         #expect(a1.list.allTags == [])
         expectMatch(a1.message, ListMessage.noReposWithPath)

         let a2 = try emptyList.addingTags(
            ["Abc"],
            includedPaths: ["~/CatPictures"]
         )
         #expect(a2.list.allTags == [])
         expectMatch(a2.message, ListMessage.noReposWithPath)

         let a3 = try cleanList.addingTags([], includedPaths: ["~/CatPictures"])
         #expect(a3.list.allTags == cleanList.allTags)
         expectMatch(a3.message, ListMessage.noReposWithPath)

         let a4 = try cleanList.addingTags(
            ["abc"],
            includedPaths: ["~/CatPictures"]
         )
         #expect(a4.list.allTags == cleanList.allTags)
         expectMatch(a4.message, ListMessage.noReposWithPath)

         let a5 = try cleanList.addingTags(
            ["b", "a"],
            includedPaths: ["~/Developer"]
         )
         #expect(a5.list.allTags == ["a", "b", "d3"])
         expectMatch(
            a5.message,
            ListMessage.tagsAdded(["a", "b"], excluded: [], repos: [d3])
         )

         let a6 = try cleanList.addingTags(
            ["d3"],
            includedPaths: ["~/Developer"]
         )
         #expect(a6.list.allTags == ["d3"])
         expectMatch(
            a6.message,
            ListMessage.tagsAdded([], excluded: ["d3"], repos: [])
         )

         let a7 = try [a, b, c].addingTags(["a"], includedPaths: [a.path])
         #expect(a7.list[0].tags == ["a"])
         #expect(a7.list[1].tags == [])
         #expect(a7.list[2].tags == [])
         expectMatch(
            a7.message,
            ListMessage.tagsAdded(["a"], excluded: [], repos: [a])
         )

         let a8 = try [a, b, c].addingTags(["c"], includedPaths: [c.path])
         #expect(a8.list[0].tags == [])
         #expect(a8.list[1].tags == [])
         #expect(a8.list[2].tags == ["c"])
         expectMatch(
            a8.message,
            ListMessage.tagsAdded(["c"], excluded: [], repos: [c])
         )
      }


      @Test
      func `adding tags to repos matching the pattern`() throws {
         let a1 = try emptyList.addingTags([], includedPaths: ["Dev"])
         #expect(a1.list.allTags == [])
         expectMatch(a1.message, ListMessage.noReposWithPath)

         let a2 = try cleanList.addingTags(["b", "a"], includedPaths: ["Dev"])
         #expect(a2.list.allTags == ["a", "b", "d3"])
         #expect(a2.list[0].tags == ["a", "b", "d3"])
         expectMatch(
            a2.message,
            ListMessage.tagsAdded(["a", "b"], excluded: [], repos: [d3])
         )

         let a3 = try [a, b, c].addingTags(["c"], includedPaths: ["Cat"])
         #expect(a3.list[0].tags == [])
         #expect(a3.list[1].tags == [])
         #expect(a3.list[2].tags == ["c"])
         expectMatch(
            a3.message,
            ListMessage.tagsAdded(["c"], excluded: [], repos: [c])
         )

         let a4 = try [a, b, c].addingTags(["c"], includedPaths: ["~"])
         #expect(a4.list[0].tags == ["c"])
         #expect(a4.list[1].tags == ["c"])
         #expect(a4.list[2].tags == ["c"])
         expectMatch(
            a4.message,
            ListMessage.tagsAdded(["c"], excluded: [], repos: [a, b, c])
         )
      }


      @Test
      func `adding tags to repos matching the pattern excluding`() throws {
         let a1 = try emptyList.addingTags(
            [],
            includedPaths: [],
            excludedPaths: ["Dev"]
         )
         #expect(a1.list.allTags == [])
         expectMatch(a1.message, ListMessage.noReposWithPath)

         let a2 = try cleanList.addingTags(
            ["b", "a"],
            includedPaths: [],
            excludedPaths: ["Dev"]
         )
         #expect(a2.list.allTags == ["d3"])
         #expect(a2.list[0].tags == ["d3"])
         expectMatch(a2.message, ListMessage.noReposWithPath)

         let a3 = try [a, b, c]
            .addingTags(["c"], includedPaths: [], excludedPaths: ["Cat"])
         #expect(a3.list[0].tags == ["c"])
         #expect(a3.list[1].tags == ["c"])
         #expect(a3.list[2].tags == [])
         expectMatch(
            a3.message,
            ListMessage.tagsAdded(["c"], excluded: [], repos: [a, b])
         )

         let a4 = try [a, b, c]
            .addingTags(["c"], includedPaths: [], excludedPaths: ["~"])
         #expect(a4.list[0].tags == [])
         #expect(a4.list[1].tags == [])
         #expect(a4.list[2].tags == [])
         expectMatch(a4.message, ListMessage.noReposWithPath)
      }


      @Test
      func
         `adding tags to repos matching the pattern case insensitive`()
         throws
      {
         let a1 = try [a, b, c].addingTags(["c"], includedPaths: ["cat"])
         #expect(a1.list.allTags == [])
         expectMatch(a1.message, ListMessage.noReposWithPath)

         let a2 = try [a, b, c].addingTags(["c"], includedPaths: ["(?i)cat"])
         #expect(a2.list[0].tags == [])
         #expect(a2.list[1].tags == [])
         #expect(a2.list[2].tags == ["c"])

         expectMatch(
            a2.message,
            ListMessage.tagsAdded(["c"], excluded: [], repos: [c])
         )
      }
   }
}
