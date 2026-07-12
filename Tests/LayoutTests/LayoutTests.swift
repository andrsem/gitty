// SPDX-FileCopyrightText: © 2026 Andrii Sem
// SPDX-License-Identifier: MIT


import Diffy
import SW40
import Testing

@testable import Layout

@Suite(.tags(.layout))
struct `Layout Tests` {
   @Test
   func `get custom layout commands`() {
      let layout = Layout(
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
            .cleanOrDirty(
               cleanFg: .green,
               cleanStyles: [.bold],
               dirtyFg: .red,
            ),
            .custom(
               command: "xyz",
               sortID: nil,
               statusInput: nil,
               width: nil,
               fg: nil,
               bg: nil,
               styles: nil,
            ),
            .modified(fg: .red),
            .added(fg: .ext(214)),
            .deleted(fg: .red),
            .custom(
               command: "ls",
               sortID: nil,
               statusInput: true,
               width: nil,
               fg: nil,
               bg: nil,
               styles: nil,
            ),
         ],
      )


      expectMatch(
         layout.customCommands,
         [
            ("xyz", false),
            ("ls", true),
         ],
      )
   }
}
