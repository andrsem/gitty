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
func `validate mini layout`() throws {
   let layout = try JSONDecoder.json5.decode(
      Layout.self,
      from: Layout.initialMini,
   )
   expectMatch(layout, defaultMini)
}


private let defaultMini = Layout(
   outputStyle: .linear,
   countMode: .trailing,
   maxCount: 9,
   maxCountStyle: .init(fg: .red),
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
      .cleanOrDirty(
         showDirty: true,
         cleanFg: .green,
         cleanStyles: [.bold],
         dirtyFg: .red,
      ),
      .separator(),
      .repo(),
      .separator(),
      .pull(hideCount: true, fg: .blue),
      .push(hideCount: true, fg: .yellow),
      .noUpstream(fg: .magenta),
      .separator(),
      .stashes(),
      .submodules(fg: .red, styles: [.italic]),
   ],
)
