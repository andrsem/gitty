// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import SW40
import Shared
import Testing

@testable import Configurator

@Test(.tags(.configurator))
func `validate base layout`() throws {
   let layout = try JSONDecoder.json5.decode(
      Layout.self,
      from: Layout.initialBase,
   )
   expectMatch(layout, defaultBase)
}


let defaultBase = Layout(
   outputStyle: .columnar,
   countMode: .trailing,
   maxCount: 99,
   maxCountStyle: .init(fg: .magenta, styles: [.underline, .bold]),
   aZSort: true,
   executionMode: .parallel,
   sortOrder: [.clean, .repo],
   truncationMode: .tail,
   symbols: Symbols(
      added: "A",
      clean: "✓",
      copied: "C",
      deleted: "D",
      detached: "⍜",
      dirty: "*",
      ignored: "!",
      initialCommit: "I",
      locked: "L",
      modified: "M",
      noUpstream: "⇞",
      pull: "↓",
      push: "↑",
      renamed: "R",
      separator: " ",
      stashes: "#",
      submodule: .init(
         prefix: "<",
         commit: "C",
         modified: "M",
         untracked: "?",
         suffix: ">",
      ),
      typeChange: "T",
      truncator: "…",
      unmerged: "U",
      untracked: "?",
   ),
   components: [
      .cleanOrDirty(cleanFg: .green, cleanStyles: [.bold]),
      .modified(fg: .red),
      .added(fg: .ext(214)),
      .deleted(fg: .red),
      .renamed(fg: .red),
      .untracked(fg: .red),
      .separator(),
      .repo(width: 18),
      .separator(),
      .pull(fg: .blue),
      .push(fg: .yellow),
      .noUpstream(fg: .magenta),
      .head(width: 10, styles: [.bold]),
      .separator(),
      .stashes(),
   ],
)
