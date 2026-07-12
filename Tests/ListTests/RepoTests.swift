// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Foundation
import Testing

@testable import List

@Suite(.tags(.list))
struct `Repo tests` {
   let d = Repo("~/Developer", [])
   let d2 = Repo("~/Developer", ["d2"])
   let d3 = Repo("~/Developer", ["d3"])
   let slashed = Repo("~/dev/", ["sl"])
   let notSlashed = Repo("~/dev", ["nsl"])
   let spaced = Repo(" ~/Developer ")


   @Test
   func `repo equality`() {
      #expect(d == spaced, "leading and trailing whitespace should be trimmed")
      #expect(d == d2, "with or without tags should be equal")
      #expect(d2 == d3, "with different tags should be equal")
      #expect(
         slashed == notSlashed,
         "with or without trailing slash should be equal",
      )
      #expect(
         Repo("~", []) == Repo(URL.homeDirectory.path(), ["home"]),
         "with or without expanded tilde should be equal",
      )
      #expect(Repo(".") == Repo(URL.currentDirectory().path()))
      #expect(
         Repo("../")
            == Repo(URL.currentDirectory().deletingLastPathComponent().path())
      )
   }

   @Test
   func `path with spaces and percent`() {
      let p = "~/Path with % spaces/and stuff"
      let e = "\(URL.homeDirectory.relativePath)/Path with % spaces/and stuff/"
      #expect(Repo(p).path == e)
   }


   @Test
   func `repo url`() {
      #expect(d.url.path() == d.path)
   }


   @Test
   func `repo hashing`() {
      #expect(d.hashValue == d2.hashValue)
      #expect(slashed.hashValue == notSlashed.hashValue)
      let home = Repo(URL.homeDirectory.appending(path: "/Developer/").path())
      #expect(d.hashValue == home.hashValue)
   }


   @Test
   func `repo comparison`() {
      let a = Repo("a", ["z"])
      let b = Repo("b", [])
      let c = Repo("c", ["x"])

      #expect(a < b)
      #expect(b < c)
      #expect(c > a)

      #expect([c, a, b].sorted() == [a, b, c])
   }


   @Test
   func `adding tags`() {
      #expect(d.adding([]).tags == d.tags)
      #expect(d.adding(["a", "b"]).tags == ["a", "b"])

      let a = Repo("a", ["z"])
      #expect(a.adding(["z"]).tags == a.tags)
      #expect(a.adding(["z", "a"]).tags == ["a", "z"])

      let a1 = a.adding(["c", "b", "a"]).tags
      #expect(
         a1 == ["a", "b", "c", "z"],
         "Adding tags should sort them",
      )

      let a2 = a.adding([" ", "none", "hello  space"]).tags
      #expect(a2 == ["z"])
   }


   @Test
   func `removing tags`() {
      #expect(d.removing([]).tags == d.tags)
      #expect(d2.removing([""]).tags == d2.tags)
      #expect(d2.removing(["abc"]).tags == d2.tags)

      #expect(d2.removing(["d2"]).tags == [])

      let a = Repo("a", ["z", "g", "z", "a", " ", "none", "star tag"])
      #expect(a.removing(["g"]).tags == ["a", "z", "z"])
   }


   @Test
   func `cleaning tags`() {
      #expect(d.cleaningTags().repo.tags == d.tags)
      #expect(d2.cleaningTags().repo.tags == d2.tags)

      let cleaned = Repo(
         "a",
         ["b", " ", " z", "a ", "z", "hello  you", "none"],
      )
      .cleaningTags()
      #expect(
         cleaned.repo.tags == ["a", "b", "z"],
         "Cleaning should also sort, and remove trailing/leading whitespace",
      )
      #expect(
         cleaned.removedTags == ["", "hello  you", "none", "z"],
         "Cleaning should remove tags with whitespace, empty tags and reserved 'none'",
      )
   }


   @Test
   func `updating tags`() {
      #expect(d.updating("", with: "").tags == d.tags)
      #expect(d.updating("a", with: "b").tags == d.tags)
      #expect(d3.updating("a", with: "b").tags == d3.tags)
      #expect(d3.updating("d3", with: "b").tags == ["b"])

      let r1 = Repo("~/abc", ["a", "b", "c"])
      #expect(r1.updating("b", with: "x").tags == ["a", "c", "x"])
      #expect(r1.updating("a", with: " b ").tags == ["b", "c"])
      #expect(r1.updating("b", with: " ").tags == r1.tags)
      #expect(r1.updating("b", with: "none").tags == r1.tags)
      #expect(r1.updating("b", with: "none").tags == r1.tags)
   }


   @Test
   func `repo contains any tags`() {
      let r1 = Repo("~/abc", ["a", "b", "c"])
      #expect(r1.containsAny([]) == false)
      #expect(r1.containsAny([""]) == false)
      #expect(r1.containsAny(["a"]) == true)
      #expect(r1.containsAny(["a", "x"]) == true)
   }


   @Test
   func `is repo path matching pattern`() throws {
      let r1 = Repo("~/abc", ["a", "b", "c"])
      #expect(true == (try r1.matchesPattern("~/ab", fixedString: false)))
      #expect(true == (try r1.matchesPattern("~/abc/", fixedString: true)))
      #expect(true == (try r1.matchesPattern("~/abc", fixedString: true)))
      #expect(true == (try r1.matchesPattern("ab", fixedString: false)))
   }


   @Test
   func `matching repo path with invalid regex`() {
      let r1 = Repo("~/abc", ["a", "b", "c"])
      #expect(throws: InvalidRegex(message: "expected ')'").self) {
         try r1.matchesPattern("(abc", fixedString: false)
      }
   }
}
