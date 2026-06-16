// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Testing

@testable import List

extension Tag {
   @Tag
   static var list: Self
}

let a = Repo("~/A", [])
let b = Repo("~/B", [])
let c = Repo("~/CatPictures", [])
let d = Repo("~/Developer", ["d"])
let d2 = Repo("~/Developer", ["d"])
let d3 = Repo("~/Developer", ["d3"])
let currentDir = Repo(".", [])
let slashed = Repo("~/dev/", ["sl"])
let notSlashed = Repo("~/dev", ["nsl"])
let emptyList = List()
var cleanList: List { [d3] }
var dirtyList: List { [c, c, d, d3, d, d2] }

extension List {
   var allTags: Tags { flatMap(\.tags) }
}


@Suite(.tags(.list))
struct `List Tests` {
   // MARK: - Adding repos

   @Test
   func `adding to empty list`() {
      #expect(emptyList.adding([]) == (emptyList, .added([])))
      #expect(emptyList.adding([a]) == ([a], .added([a])))
      #expect(emptyList.adding([a, a, a]) == ([a], .added([a])))
      #expect(emptyList.adding([d, d3, d2]) == ([d], .added([d])))
      #expect(
         emptyList.adding([currentDir])
            == ([currentDir], .added([currentDir]))
      )
      #expect(
         emptyList
            .adding([currentDir]).list
            .cleaning(isPathValid: { _ in true })
            == [currentDir]
      )
   }

   @Test
   func `adding to non empty list`() {
      let list = [a]
      #expect(list.adding([a]) == (list, .added([])))
      #expect(list.adding([a, b]) == ([a, b], .added([b])))
   }

   @Test
   func `adding with the same path`() {
      let list2 = [d]
      #expect(list2.adding([d, d3, d2]) == ([d], .added([])))

      let list3 = [d, d3]
      #expect(list3.adding([d, d3, d2]) == ([d, d3], .added([])))
   }

   @Test
   func `adding with the same path different tags`() {
      let list = [d]
      #expect(list.adding([d3]) == (list, .added([])))
      #expect(list.adding([d2, d3]) == (list, .added([])))
   }

   @Test
   func `adding with or without trailing slash`() {
      #expect(
         [notSlashed].adding([slashed])
            == ([notSlashed], .added([]))
      )
      #expect(
         [slashed].adding([notSlashed])
            == ([slashed], .added([]))
      )
   }

   @Test
   func `adding with duplicate tags`() {
      let expectedList = [Repo("~/gg", ["a", "y"])]
      #expect(
         emptyList.adding([Repo("~/gg", ["a", "y", "a", "y"])])
            == (expectedList, .added([Repo("~/gg", ["a", "y"])]))
      )
   }


   // MARK: - Cleaning repos

   @Test
   func `cleaning repos`() {
      #expect(emptyList.cleaning { _ in false } == emptyList, )
      #expect(cleanList.cleaning { _ in true } == cleanList, )
      #expect(cleanList.cleaning { _ in false } == emptyList, )
      #expect(dirtyList.cleaning { _ in true } == [c, d], )

      #expect(
         [slashed, notSlashed].cleaning { _ in true } == [slashed],
         "With or without trailing slash duplicate should be cleaned"
      )

      let listWithTagDups = [Repo("a", ["abc", "g", "abc", "y"])]
      let expectedListNoTagDups = [Repo("a", ["abc", "g", "y"])]
      #expect(listWithTagDups.cleaning { _ in true } == expectedListNoTagDups)
   }


   @Test(arguments: ["(?idev", "?dev", "[dev"])
   func `removing repos using invalid regex`(repo: String) throws {
      #expect(throws: InvalidRegex.self) { try cleanList.removing(repo) }
   }


   // MARK: - Removing repos


   @Test
   func `removing repos`() throws {
      #expect(try emptyList.removing("") == (emptyList, .removed([])))
      #expect(try emptyList.removing("cat") == (emptyList, .removed([])))
      #expect(try cleanList.removing("cat") == (cleanList, .removed([])))
      #expect(
         try cleanList
            .removing(d.path, fixedString: false) == (emptyList, .removed([d]))
      )
      #expect(
         try cleanList
            .removing(d.path, fixedString: true) == (emptyList, .removed([d]))
      )
      #expect(try cleanList.removing("Dev") == (emptyList, .removed([d])))
      #expect(try cleanList.removing(d.path) == (emptyList, .removed([d])))
      #expect(try cleanList.removing("(?i)dev") == (emptyList, .removed([d])))
      #expect(
         try dirtyList.removing("Dev")
            == ([c, c], .removed([d, d, d, d]))
      )
      #expect(
         try dirtyList.removing("~/Developer")
            == ([c, c], .removed([d, d, d, d]))
      )
      #expect(
         try dirtyList.removing("(?i)dev|pic")
            == (emptyList, .removed([c, c, d, d, d, d]))
      )


      #expect(
         try dirtyList.removing("Cat")
            == ([d, d, d2, d], .removed([c, c]))
      )

      #expect(
         try dirtyList.removing("(?i)cat")
            == ([d, d, d2, d], .removed([c, c]))
      )
   }


   // MARK: - Filtering repos

   @Test
   func `filter repos by tags`() {
      let list = [a, d, d2, b, d3]
      #expect(list.filterReposByTags([]) == list)
      #expect(list.filterReposByTags([""]) == [])
      #expect(list.filterReposByTags(["d"]) == [d, d])
      #expect(list.filterReposByTags(["d", "d3"]) == [d, d2, d3])
      #expect(list.filterReposByTags(["none"]) == [a, b])
      #expect(list.filterReposByTags(["none", "d3"]) == [a, b, d3])

      let f1 = list.filterReposByTags(["d"], excluding: true)
      #expect(f1 == [a, b, d3])

      let f2 = list.filterReposByTags(["none"], excluding: true)
      #expect(f2 == [d, d2, d3])

      let f3 = list.filterReposByTags(["none", "d3"], excluding: true)
      #expect(f3 == [d, d2])

      let f4 = list.filterReposByTags(["none", "d3", "d"], excluding: true)
      #expect(f4 == [])
   }


   @Test(arguments: ["~/A", "~/A/"])
   func `filter repos by path fixed string`(path: String) throws {
      let list = [a, b, c]
      let r1 = try list.filterReposByPath([], fixedString: true)
      #expect(list == r1)

      let r2 = try list.filterReposByPath([path], fixedString: true)
      #expect([a] == r2)

      let r3 = try list.filterReposByPath(
         [],
         excludedPaths: [path],
         fixedString: true
      )
      #expect([b, c] == r3)
   }


   @Test
   func `filter repos by path`() throws {
      let list = [a, b, c]

      let r1 = try list.filterReposByPath([])
      #expect(list == r1)

      let r2 = try list.filterReposByPath(["A"])
      #expect([a] == r2)

      let r3 = try list.filterReposByPath(["(?i)(a|b)/$"])
      #expect([a, b] == r3)

      let r4 = try list.filterReposByPath([], excludedPaths: ["A"])
      #expect([b, c] == r4)
   }


   @Test
   func `filter repo by path invalid regex`() throws {
      let list = [a, b, c]

      #expect(throws: InvalidRegex(message: "Invalid path regex: expected ')'"))
      {
         try list.filterReposByPath(["(A"])
      }


      #expect(throws: InvalidRegex(message: "Invalid path regex: expected ']'"))
      {
         try list.filterReposByPath(["[A"])
      }
   }


   @Test
   func `validate tags`() throws {
      let list = [d, slashed]
      let tags = (d.tags + slashed.tags).sorted()
      #expect(([], tags) == list.validateTags(in: []))
      #expect(([], tags) == list.validateTags(in: ["none"]))
      #expect((["gg"], tags) == list.validateTags(in: ["gg"]))
      #expect(
         (["ab", "cd"], tags) == list.validateTags(in: ["ab", "cd"])
      )
   }
}
