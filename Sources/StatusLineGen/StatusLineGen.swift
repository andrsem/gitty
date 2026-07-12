// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

package import Foundation
package import Layout
import SW40
import Shared
package import Status

package typealias StatusLine = (line: String, sortID: String)
package typealias CustomOutput = (command: String, output: String)
typealias Column = (value: String, sortID: String)


package func generateStatusLine(
   for repo: URL,
   layout: Layout,
   status: Status,
   custom: [CustomOutput] = [],
) -> StatusLine {
   StatusLineGen(repo: repo, layout: layout, status: status, custom: custom)
      .run()
}


struct StatusLineGen {
   let repo: URL
   let layout: Layout
   let status: Status
   let custom: [CustomOutput]


   var emptyStr: String { layout.outputStyle == .linear ? "" : " " }


   func run() -> StatusLine {
      let columns =
         layout
         .components
         .reduce(into: [(comp: StatusComponent, column: Column)]()) {
            let isConsecutiveSeparatorHidden =
               layout.outputStyle == .linear
               ? $1 == $0.last?.comp
               : false

            let status = componentStatus(
               for: $1,
               isSeparatorHidden: isConsecutiveSeparatorHidden,
            )

            guard !status.value.isEmpty else { return }

            $0.append(($1, status))
         }

      let line = columns.map(\.column.value).joined()
      let sortID =
         columns.map(\.column.sortID)
         .removedAll { $0.hasPrefix(Self.unsortedPrefixID) }
         |> { $0.kept + $0.removed }
         |> { $0.joined() }

      return (line, sortID)
   }


   private func componentStatus(
      for component: StatusComponent,
      isSeparatorHidden: Bool,
   ) -> Column {
      switch component {
      case let .added(fg, bg, s): added(fg, bg, s)
      case let .copied(fg, bg, s): copied(fg, bg, s)
      case let .custom(c, id, _, w, m, fg, bg, styles):
         custom(c, id, w, m, fg, bg, styles)
      case let .deleted(fg, bg, s): deleted(fg, bg, s)
      case let .detached(fg, bg, s): detached(fg, bg, s)
      case let .head(width, m, fg, bg, s): head(width, m, fg, bg, s)
      case let .ignored(fg, bg, s): ignored(fg, bg, s)
      case let .initialCommit(fg, bg, s): initialCommit(fg, bg, s)
      case let .locked(fg, bg, s): locked(fg, bg, s)
      case let .modified(fg, bg, s): modified(fg, bg, s)
      case let .noUpstream(fg, bg, s): noUpstream(fg, bg, s)
      case let .oid(length, fg, bg, s): oid(length, fg, bg, s)
      case let .cleanOrDirty(a, oFg, oBg, oS, aFg, aBg, aS):
         cleanOrDirty(a, oFg, oBg, oS, aFg, aBg, aS)
      case let .pull(hideCount, fg, bg, s): pull(hideCount, fg, bg, s)
      case let .push(hideCount, fg, bg, s): push(hideCount, fg, bg, s)
      case let .renamed(fg, bg, s): renamed(fg, bg, s)
      case let .repo(width, m, isFull, fg, bg, s):
         repo(width, m, isFull, fg, bg, s)
      case let .separator(v, fg, bg, s):
         separator(v, fg, bg, s, isHidden: isSeparatorHidden)
      case let .stashes(hideCount, fg, bg, s): stashes(hideCount, fg, bg, s)
      case let .submodules(comp, fg, bg, s): submodules(comp, fg, bg, s)
      case let .typeChange(fg, bg, s): typeChange(fg, bg, s)
      case let .unmerged(fg, bg, s): unmerged(fg, bg, s)
      case let .untracked(fg, bg, s): untracked(fg, bg, s)
      case let .upstream(width, m, fg, bg, s): upstream(width, m, fg, bg, s)
      }
   }
}
