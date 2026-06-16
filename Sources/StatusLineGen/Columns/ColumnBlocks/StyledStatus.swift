// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import TTS

extension String {
   func styledStatus(
      _ styles: [TextStyle]?,
      fg: TextColor?,
      bg: TextColor?,
      isVisible: Bool = true,
      emptyStr: String,
   ) -> Self {
      isVisible
         ? self
            .applyFgColor(fg)
            .applyBgColor(bg)
            .applyTextStyles(styles)

         : String(repeating: emptyStr, count: self.count)
   }


   private func applyFgColor(_ color: TextColor?) -> Self {
      guard !isEmpty, let color else { return self }

      return switch color {
      case .red: fg(.red)
      case .green: fg(.green)
      case .white: fg(.white)
      case .black: fg(.black)
      case .yellow: fg(.yellow)
      case .blue: fg(.blue)
      case .magenta: fg(.magenta)
      case .cyan: fg(.cyan)
      case .brightRed: fg(.brightRed)
      case .brightGreen: fg(.brightGreen)
      case .brightWhite: fg(.brightWhite)
      case .brightBlack: fg(.brightBlack)
      case .brightYellow: fg(.brightYellow)
      case .brightBlue: fg(.brightBlue)
      case .brightMagenta: fg(.brightMagenta)
      case .brightCyan: fg(.brightCyan)
      case let .ext(code): fg(code)
      case let .hex(value): fg(.hex(value))
      case let .rgb(r, g, b): fg(.rgb(r, g, b))
      case let .hsb(h, s, b): fg(.hsb(h, s, b))
      }
   }


   private func applyBgColor(_ color: TextColor?) -> Self {
      guard !isEmpty, let color else { return self }

      return switch color {
      case .red: bg(.red)
      case .green: bg(.green)
      case .white: bg(.white)
      case .black: bg(.black)
      case .yellow: bg(.yellow)
      case .blue: bg(.blue)
      case .magenta: bg(.magenta)
      case .cyan: bg(.cyan)
      case .brightRed: bg(.brightRed)
      case .brightGreen: bg(.brightGreen)
      case .brightWhite: bg(.brightWhite)
      case .brightBlack: bg(.brightBlack)
      case .brightYellow: bg(.brightYellow)
      case .brightBlue: bg(.brightBlue)
      case .brightMagenta: bg(.brightMagenta)
      case .brightCyan: bg(.brightCyan)
      case let .ext(code): bg(code)
      case let .hex(value): bg(.hex(value))
      case let .rgb(r, g, b): bg(.rgb(r, g, b))
      case let .hsb(h, s, b): bg(.hsb(h, s, b))
      }
   }


   private func applyTextStyles(_ styles: [TextStyle]?) -> Self {
      guard !isEmpty, let styles, !styles.isEmpty else { return self }

      return
         styles.reduce(self) {
            switch $1 {
            case .bold: $0.styles(.bold)
            case .faint: $0.styles(.faint)
            case .italic: $0.styles(.italic)
            case .underline: $0.styles(.underline)
            case .blink: $0.styles(.blink)
            case .fastBlink: $0.styles(.fastBlink)
            case .reverse: $0.styles(.reverse)
            case .erase: $0.styles(.erase)
            case .strikethrough: $0.styles(.strikethrough)
            case .fraktur: $0.styles(.fraktur)
            case .doubleUnderline: $0.styles(.doubleUnderline)
            }
         }
   }
}
