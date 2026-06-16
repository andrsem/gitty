// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package import SW40

package enum StatusComponent: Decodable, Equatable, Sendable {
   case added(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case copied(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case custom(
      command: String,
      sortID: String? = nil,
      statusInput: Bool? = nil,
      width: Int? = nil,
      truncationMode: TruncationMode? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case deleted(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case detached(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case head(
      width: Int? = nil,
      truncationMode: TruncationMode? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case ignored(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case locked(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case modified(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case initialCommit(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case noUpstream(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case oid(
      length: Int? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case cleanOrDirty(
      showDirty: Bool? = nil,
      cleanFg: TextColor? = nil,
      cleanBg: TextColor? = nil,
      cleanStyles: [TextStyle]? = nil,
      dirtyFg: TextColor? = nil,
      dirtyBg: TextColor? = nil,
      dirtyStyles: [TextStyle]? = nil
   )
   case pull(
      hideCount: Bool? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case push(
      hideCount: Bool? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case renamed(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case repo(
      width: Int? = nil,
      truncationMode: TruncationMode? = nil,
      fullPath: Bool? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case separator(
      symbol: String? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case stashes(
      hideCount: Bool? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case submodules(
      components: [Submodule]? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case typeChange(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case unmerged(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case untracked(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )
   case upstream(
      width: Int? = nil,
      truncationMode: TruncationMode? = nil,
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil
   )



   package enum Submodule: Decodable, Equatable, Sendable {
      case commit(
         fg: TextColor? = nil,
         bg: TextColor? = nil,
         styles: [TextStyle]? = nil
      )
      case modified(
         fg: TextColor? = nil,
         bg: TextColor? = nil,
         styles: [TextStyle]? = nil
      )
      case untracked(
         fg: TextColor? = nil,
         bg: TextColor? = nil,
         styles: [TextStyle]? = nil
      )
   }
}
