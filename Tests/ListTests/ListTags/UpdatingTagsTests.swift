// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Shared
import Testing

@testable import List

extension `List Tests` {
   @Suite
   struct `Updating tags` {
      @Test
      func `updating tag in all repos`() throws {
         let u1 = try emptyList.updatingTags(["old", "new"], includedPaths: [])
         #expect(u1.list.allTags == [])
         expectMatch(u1.message, ListMessage.noReposWithPath)

         let u2 = try cleanList.updatingTags(["old", "new"], includedPaths: [])
         #expect(u2.list.allTags == ["d3"])
         expectMatch(
            u2.message,
            ListMessage.tagsNotUpdated(old: "old", new: "new")
         )

         let u3 = try cleanList.updatingTags(["d3", "new"], includedPaths: [])
         #expect(u3.list.allTags == ["new"])
         expectMatch(
            u3.message,
            ListMessage.tagsUpdated(
               old: "d3",
               new: "new",
               repos: [ListTests.d3]
            )
         )

         let u4 = try cleanList.updatingTags(["old"], includedPaths: [])
         #expect(u4.list.allTags == ["d3"])
         expectMatch(u4.message, ListMessage.noOldNewForUpdate)

         let r1 = Repo("~/repo1", ["a", "b"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", ["c"])

         let u5 = try [r1, r2, r3]
            .updatingTags(["c", "new"], includedPaths: [])
         #expect(u5.list[0].tags == ["a", "b"])
         #expect(u5.list[1].tags == ["b"])
         #expect(u5.list[2].tags == ["new"])
         expectMatch(
            u5.message,
            ListMessage.tagsUpdated(old: "c", new: "new", repos: [r3])
         )
      }


      @Test
      func `updating tag with tag with edge whitespace`() throws {
         let u3 = try cleanList.updatingTags(
            ["d3", " new "],
            includedPaths: []
         )
         #expect(u3.list.allTags == ["new"])
         expectMatch(
            u3.message,
            ListMessage.tagsUpdated(
               old: "d3",
               new: "new",
               repos: [ListTests.d3]
            )
         )
      }


      @Test
      func `updating tag in specific repo`() throws {
         let r1 = Repo("~/repo1", ["a", "new"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", ["c"])

         let u1 = try [r1, r2, r3]
            .updatingTags(["old", "new"], includedPaths: ["~/repo1"])
         #expect(u1.list[0].tags == ["a", "new"])
         #expect(u1.list[1].tags == ["b"])
         #expect(u1.list[2].tags == ["c"])
         expectMatch(
            u1.message,
            ListMessage.tagsNotUpdated(old: "old", new: "new")
         )

         let u2 = try [r1, r2, r3]
            .updatingTags(["xyz", "new"], includedPaths: ["~/repo2"])
         #expect(u2.list[0].tags == ["a", "new"])
         #expect(u2.list[1].tags == ["b"])
         #expect(u2.list[2].tags == ["c"])
         expectMatch(
            u2.message,
            ListMessage.tagsNotUpdated(old: "xyz", new: "new")
         )

         let u3 = try [r1, r2, r3]
            .updatingTags(["c", "new"], includedPaths: ["~/repo3"])
         #expect(u3.list[0].tags == ["a", "new"])
         #expect(u3.list[1].tags == ["b"])
         #expect(u3.list[2].tags == ["new"])
         expectMatch(
            u3.message,
            ListMessage.tagsUpdated(old: "c", new: "new", repos: [r3])
         )

         let u4 = try [r1, r2, r3]
            .updatingTags(["old", "new"], includedPaths: ["~/abc"])
         #expect(u4.list[0].tags == ["a", "new"])
         #expect(u4.list[1].tags == ["b"])
         #expect(u4.list[2].tags == ["c"])
         expectMatch(u4.message, ListMessage.noReposWithPath)
      }


      @Test
      func `updating tag matching repo inverted`() throws {
         let r1 = Repo("~/repo1", ["a", "new"])
         let r2 = Repo("~/repo2", ["a", "b"])
         let r3 = Repo("~/repo3", ["c"])

         let u1 = try [r1, r2, r3]
            .updatingTags(
               ["old", "new"],
               includedPaths: [],
               excludedPaths: ["repo1"]
            )
         #expect(u1.list[0].tags == ["a", "new"])
         #expect(u1.list[1].tags == ["a", "b"])
         #expect(u1.list[2].tags == ["c"])
         expectMatch(
            u1.message,
            ListMessage.tagsNotUpdated(old: "old", new: "new")
         )

         let u2 = try [r1, r2, r3]
            .updatingTags(
               ["xyz", "new"],
               includedPaths: [],
               excludedPaths: ["repo2"]
            )
         #expect(u2.list[0].tags == ["a", "new"])
         #expect(u2.list[1].tags == ["a", "b"])
         #expect(u2.list[2].tags == ["c"])
         expectMatch(
            u2.message,
            ListMessage.tagsNotUpdated(old: "xyz", new: "new")
         )

         let u3 = try [r1, r2, r3]
            .updatingTags(
               ["c", "new"],
               includedPaths: [],
               excludedPaths: ["repo3"]
            )
         #expect(u3.list[0].tags == ["a", "new"])
         #expect(u3.list[1].tags == ["a", "b"])
         #expect(u3.list[2].tags == ["c"])
         expectMatch(
            u3.message,
            ListMessage.tagsNotUpdated(old: "c", new: "new")
         )

         let u4 = try [r1, r2, r3]
            .updatingTags(
               ["old", "new"],
               includedPaths: [],
               excludedPaths: ["abc"]
            )
         #expect(u4.list[0].tags == ["a", "new"])
         #expect(u4.list[1].tags == ["a", "b"])
         #expect(u4.list[2].tags == ["c"])
         expectMatch(
            u4.message,
            ListMessage.tagsNotUpdated(old: "old", new: "new")
         )

         let u5 = try [r1, r2, r3]
            .updatingTags(
               ["a", "aa"],
               includedPaths: [],
               excludedPaths: ["repo1"]
            )
         #expect(u5.list[0].tags == ["a", "new"])
         #expect(u5.list[1].tags == ["aa", "b"])
         #expect(u5.list[2].tags == ["c"])
         expectMatch(
            u5.message,
            ListMessage.tagsUpdated(old: "a", new: "aa", repos: [r2])
         )
      }


      @Test(arguments: ["new a", "", " "])
      func `updating tag with invalid tag`(newTag: String) throws {
         let r1 = Repo("~/repo1", ["a"])

         let u1 = try [r1].updatingTags(["a", newTag], includedPaths: ["repo"])
         #expect(u1.list[0].tags == ["a"])

         let expectedMessage = ListMessage.tagsNotUpdated(
            old: "a",
            new: newTag.trimmedWN
         )
         #expect(u1.message == expectedMessage)
      }


      @Test
      func `updating tag in repos matching the pattern`() throws {
         let r1 = Repo("~/repo1", ["a", "new"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", ["c"])

         let u1 = try [r1, r2, r3]
            .updatingTags(["old", "new"], includedPaths: ["repo"])
         #expect(u1.list[0].tags == ["a", "new"])
         #expect(u1.list[1].tags == ["b"])
         #expect(u1.list[2].tags == ["c"])
         expectMatch(
            u1.message,
            ListMessage.tagsNotUpdated(old: "old", new: "new")
         )

         let u2 = try [r1, r2, r3]
            .updatingTags(["xyz", "new"], includedPaths: ["po"])
         #expect(u2.list[0].tags == ["a", "new"])
         #expect(u2.list[1].tags == ["b"])
         #expect(u2.list[2].tags == ["c"])
         expectMatch(
            u2.message,
            ListMessage.tagsNotUpdated(old: "xyz", new: "new")
         )

         let u3 = try [r1, r2, r3]
            .updatingTags(["c", "new"], includedPaths: ["re"])
         #expect(u3.list[0].tags == ["a", "new"])
         #expect(u3.list[1].tags == ["b"])
         #expect(u3.list[2].tags == ["new"])
         expectMatch(
            u3.message,
            ListMessage.tagsUpdated(old: "c", new: "new", repos: [r3])
         )

         let u4 = try [r1, r2, r3]
            .updatingTags(["old", "new"], includedPaths: ["abc"])
         #expect(u4.list[0].tags == ["a", "new"])
         #expect(u4.list[1].tags == ["b"])
         #expect(u4.list[2].tags == ["c"])
         expectMatch(u4.message, ListMessage.noReposWithPath)
      }


      @Test
      func `updating tag in repos insensitively matching the pattern`() throws {
         let r1 = Repo("~/repo1", ["a", "new"])
         let r2 = Repo("~/repo2", ["b"])
         let r3 = Repo("~/repo3", ["c"])

         let u1 = try [r1, r2, r3]
            .updatingTags(["old", "new"], includedPaths: ["(?i)Repo"])
         #expect(u1.list[0].tags == ["a", "new"])
         #expect(u1.list[1].tags == ["b"])
         #expect(u1.list[2].tags == ["c"])
         expectMatch(
            u1.message,
            ListMessage.tagsNotUpdated(old: "old", new: "new")
         )

         let u2 = try [r1, r2, r3]
            .updatingTags(["xyz", "new"], includedPaths: ["(?i)rEPo"])
         #expect(u2.list[0].tags == ["a", "new"])
         #expect(u2.list[1].tags == ["b"])
         #expect(u2.list[2].tags == ["c"])
         expectMatch(
            u2.message,
            ListMessage.tagsNotUpdated(old: "xyz", new: "new")
         )

         let u4 = try [r1, r2, r3]
            .updatingTags(["old", "new"], includedPaths: ["abc"])
         #expect(u4.list[0].tags == ["a", "new"])
         #expect(u4.list[1].tags == ["b"])
         #expect(u4.list[2].tags == ["c"])
         expectMatch(u4.message, ListMessage.noReposWithPath)
      }
   }
}
