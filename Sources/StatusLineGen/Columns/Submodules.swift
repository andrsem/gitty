// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import SW40
import Status

extension StatusLineGen {
   func submodules(
      _ components: [StatusComponent.Submodule]?,
      _ fg: TextColor?,
      _ bg: TextColor?,
      _ styles: [TextStyle]?,
   ) -> Column {
      let subStatus = status.changedEntries.hasSubmoduleChanges()

      func componentHasChange(_ component: StatusComponent.Submodule) -> Bool {
         switch component {
         case .commit: subStatus.commit
         case .modified: subStatus.modified
         case .untracked: subStatus.untracked
         }
      }

      let components = (components ?? [])

      let hasSubChanges =
         components.isEmpty
         ? (subStatus.commit || subStatus.modified || subStatus.untracked)
         : components.contains(where: componentHasChange)

      let commitSymbol = layout.symbols.submodule.commit
      let modifiedSymbol = layout.symbols.submodule.modified
      let untrackedSymbol = layout.symbols.submodule.untracked

      let compLength =
         components
         .reduce(0) {
            let count =
               switch $1 {
               case .commit: commitSymbol.count
               case .modified: modifiedSymbol.count
               case .untracked: untrackedSymbol.count
               }

            return $0 + count
         }

      let componentStr =
         {
            var str = ""
            str.reserveCapacity(compLength)
            return str
         }()

      let styledComps =
         components
         .reduce(componentStr) {
            let component =
               switch $1 {
               case let .commit(fg, bg, s):
                  commitSymbol
                     .styledStatus(s, fg: fg, bg: bg, emptyStr: emptyStr)
               case let .modified(fg, bg, s):
                  modifiedSymbol
                     .styledStatus(s, fg: fg, bg: bg, emptyStr: emptyStr)
               case let .untracked(fg, bg, s):
                  untrackedSymbol
                     .styledStatus(s, fg: fg, bg: bg, emptyStr: emptyStr)
               }

            let result =
               switch (layout.outputStyle, componentHasChange($1)) {
               case (_, true): component
               case (.linear, false): ""
               case (.columnar, false): " "
               }

            return $0 + result
         }

      let prefix = layout.symbols.submodule.prefix
      let suffix = layout.symbols.submodule.suffix

      let result =
         switch (layout.outputStyle, hasSubChanges) {
         case (.linear, true):
            prefix.styledStatus(styles, fg: fg, bg: bg, emptyStr: emptyStr)
               + styledComps
               + suffix.styledStatus(styles, fg: fg, bg: bg, emptyStr: emptyStr)

         case (.linear, false):
            emptySpace(length: prefix.count + compLength + suffix.count)

         case (.columnar, _):
            (prefix
               + styledComps.ifEmpty(String(repeating: " ", count: compLength))
               + suffix)
               .styledStatus(
                  styles,
                  fg: fg,
                  bg: bg,
                  isVisible: hasSubChanges,
                  emptyStr: emptyStr
               )
         }

      let sortID = Self.generateSortID(
         for: .submodules,
         with: "sub:",
         isAZ: hasSubChanges |> layout.selectSortDirection,
         sortOrder: layout.sortOrder
      )

      return (result, sortID)
   }
}
