// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import SW40
import Status

let allComponents: [StatusComponent] = [
   .added(),
   .copied(),
   .custom(command: "pwd"),
   .deleted(),
   .detached(),
   .ignored(),
   .initialCommit(),
   .locked(),
   .modified(),
   .noUpstream(),
   .pull(),
   .push(),
   .renamed(),
   .stashes(),
   .submodules(
      components: [
         .commit(),
         .modified(),
         .untracked(),
      ]
   ),
   .typeChange(),
   .unmerged(),
   .untracked(),

   .oid(),
   .head(),
   .cleanOrDirty(),
   .repo(),
   .separator(),
   .upstream(),
]

func symbols(
   added: String = "A",
   clean: String = "✓",
   copied: String = "C",
   deleted: String = "D",
   detached: String = "⍜",
   dirty: String = "*",
   ignored: String = "!",
   initialCommit: String = "I",
   locked: String = "L",
   modified: String = "M",
   noUpstream: String = "⇞",
   pull: String = "↓",
   push: String = "↑",
   renamed: String = "R",
   separator: String = " ",
   stashes: String = "#",
   submodule: Symbols.Submodule = .init(
      prefix: "<",
      commit: "C",
      modified: "M",
      untracked: "?",
      suffix: ">",
   ),
   typeChange: String = "T",
   truncator: String = "…",
   unmerged: String = "U",
   untracked: String = "?",
) -> Symbols {
   Symbols(
      added: added,
      clean: clean,
      copied: copied,
      deleted: deleted,
      detached: detached,
      dirty: dirty,
      ignored: ignored,
      initialCommit: initialCommit,
      locked: locked,
      modified: modified,
      noUpstream: noUpstream,
      pull: pull,
      push: push,
      renamed: renamed,
      separator: separator,
      stashes: stashes,
      submodule: submodule,
      typeChange: typeChange,
      truncator: truncator,
      unmerged: unmerged,
      untracked: untracked,
   )
}


func layout(
   _ outputStyle: OutputStyle = .columnar,
   countMode: CountMode = .trailing,
   maxCount: Int = 99,
   maxCountStyle: CountStyle = .init(),
   aZSort: Bool = true,
   sortOrder: [SortComponent] = [],
   truncationMode: TruncationMode = .tail,
   symbols: Symbols = symbols(),
   components: [StatusComponent] = [],
) -> Layout {
   Layout(
      outputStyle: outputStyle,
      countMode: countMode,
      maxCount: maxCount,
      maxCountStyle: maxCountStyle,
      aZSort: aZSort,
      executionMode: .parallel,
      sortOrder: sortOrder,
      truncationMode: truncationMode,
      symbols: symbols,
      components: components,
   )
}


func status(
   oid: String = "fbc7d6adbcabc6db5b470d48b9ea37ef3c5ad35e",
   head: String = "main",
   upstream: String = "origin/main",
   pullCount: Int = .zero,
   pushCount: Int = .zero,
   stashCount: Int = .zero,
   isLocked: Bool = false,
   changedEntries: Set<TrackedEntryChange> = [],
) -> Status {
   Status(
      oid: oid,
      head: head,
      upstream: upstream,
      pullCount: pullCount,
      pushCount: pushCount,
      stashCount: stashCount,
      isLocked: isLocked,
      changedEntries: changedEntries,
   )
}


let cleanStatus = status()
