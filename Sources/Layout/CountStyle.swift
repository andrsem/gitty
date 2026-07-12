// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package struct CountStyle: Decodable, Equatable, Sendable {
   package init(
      fg: TextColor? = nil,
      bg: TextColor? = nil,
      styles: [TextStyle]? = nil,
   ) {
      self.fg = fg
      self.bg = bg
      self.styles = styles
   }

   package let fg: TextColor?
   package let bg: TextColor?
   package let styles: [TextStyle]?
}
