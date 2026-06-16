// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import Aliases

extension Tag {
   @Tag
   static var aliases: Self
}

@Suite(.tags(.aliases))
struct `Alias Tests` {
   @Test(arguments: ["", " ", "a b", " a c"])
   func `invalid Alias name`(name: String) {
      #expect(throws: AliasError.invalidName) {
         try Alias(name, args: ["ls"])
      }
   }


   @Test(arguments: ["a", " b", "ab", " ac "])
   func `valid Alias name`(name: String) {
      #expect(throws: Never.self) {
         try Alias(name, args: ["ls"])
      }
   }


   @Test
   func `invalid Alias command`() {
      #expect(throws: AliasError.invalidCommand) {
         try Alias("ls", args: [])
      }
   }


   @Test(arguments: ["ls", "ls -l", " ls -l -a "])
   func `valid Alias command`(command: String) {
      #expect(throws: Never.self) {
         try Alias("ls", args: [command])
      }
   }


   @Test(arguments: [Alias.Flag.allCases, [.compact], [.parallel, .quiet]])
   func `alias with flags`(flags: [Alias.Flag]) throws {
      let a1 = try #require(try? Alias("ls", args: ["ls"], flags: flags))
      #expect(a1.flags == flags)
   }


   @Test
   func `alias with status filters`() throws {
      let a1 = try #require(
         try? Alias("ls", args: ["ls"], status: [])
      )
      #expect(a1.status == [])

      let multipleFilters: [Alias.StatusFilter] = [.modified, .ignored, .added]

      let a2 = try #require(
         try? Alias("ls", args: ["ls"], status: multipleFilters)
      )
      #expect(a2.status == multipleFilters)
   }


   @Test(arguments: Alias.StatusFilter.allCases)
   func `alias with valid status filters`(filter: Alias.StatusFilter) throws {
      let a1 = try #require(
         try? Alias("ls", args: ["ls"], status: [filter])
      )
      #expect(a1.status == [filter])
   }


   @Test
   func `aliases are compared only by name`() throws {
      let a = try Alias(
         "a",
         args: ["z"],
         details: "z",
         flags: [.quiet],
         status: [.untracked],
         delay: 1,
         sort: .za
      )

      let b = try Alias(
         "b",
         args: ["b"],
         details: "b",
         flags: [.parallel],
         status: [.copied],
         delay: 2,
         sort: .unsorted
      )

      let z = try Alias(
         "z",
         args: ["a"],
         details: "a",
         flags: [.compact],
         status: [.added],
         delay: 0,
         sort: .az
      )

      let sorted = [b, z, a].sorted()
      #expect(sorted == [a, b, z])
   }
}
