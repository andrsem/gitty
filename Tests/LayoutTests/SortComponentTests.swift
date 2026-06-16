// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT

import Testing

@testable import Layout

@Suite(.tags(.layout))
struct `Sort Component Tests` {
   typealias Pair = (raw: String, component: SortComponent)

   @Test(
      arguments: [Pair]([
         ("head", .head),
         ("oid", .oid),
         ("repo", .repo),
         ("upstream", .upstream),
         ("added", .added),
         ("!added", ._added),
         ("copied", .copied),
         ("!copied", ._copied),
         ("deleted", .deleted),
         ("!deleted", ._deleted),
         ("detached", .detached),
         ("!detached", ._detached),
         ("ignored", .ignored),
         ("!ignored", ._ignored),
         ("initialCommit", .initialCommit),
         ("!initialCommit", ._initialCommit),
         ("locked", .locked),
         ("!locked", ._locked),
         ("modified", .modified),
         ("!modified", ._modified),
         ("noUpstream", .noUpstream),
         ("!noUpstream", ._noUpstream),
         ("clean", .clean),
         ("!clean", ._clean),
         ("pull", .pull),
         ("!pull", ._pull),
         ("push", .push),
         ("!push", ._push),
         ("renamed", .renamed),
         ("!renamed", ._renamed),
         ("stashes", .stashes),
         ("!stashes", ._stashes),
         ("submodules", .submodules),
         ("!submodules", ._submodules),
         ("typeChange", .typeChange),
         ("!typeChange", ._typeChange),
         ("unmerged", .unmerged),
         ("!unmerged", ._unmerged),
         ("untracked", .untracked),
         ("!untracked", ._untracked),
         ("custom: abc", .custom("abc")),
         ("custom:abc", .custom("abc")),
         ("custom:   abc   ", .custom("abc")),
      ])
   )
   func `initialize from valid rawValue`(pair: Pair) {
      let component = SortComponent(rawValue: pair.raw)
      #expect(component == pair.component)
   }


   @Test(
      arguments: [
         "ooops",
         "",
         "custom aa",
         "custom:",
      ]
   )
   func `initialize from invalid rawValue`(raw: String) {
      let component = SortComponent(rawValue: raw)
      #expect(component == nil)
   }
}
