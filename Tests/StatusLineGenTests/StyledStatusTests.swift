// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Layout
import TTS
import Testing

@testable import StatusLineGen

@Suite(.tags(.statusLineGen))
struct `Styled status Tests` {
   @Test(arguments: ["", " ", "  "])
   func `apply when is not visible`(emptyStr: String) {
      let r = "a"
         .styledStatus(
            [.bold],
            fg: .blue,
            bg: .red,
            isVisible: false,
            emptyStr: emptyStr,
         )

      #expect(r == emptyStr)
   }


   @Test()
   func `apply when is visible`() {
      let r = "a"
         .styledStatus(
            [.bold],
            fg: .blue,
            bg: .red,
            isVisible: true,
            emptyStr: "",
         )
      let e = "a".fg(.blue).bg(.red).styles([.bold])
      #expect(r == e)
   }


   @Test(arguments: Self.styles)
   func `apply styles`(style: (Style, [TextStyle])) {
      let r = "a"
         .styledStatus(
            style.1,
            fg: nil,
            bg: nil,
            isVisible: true,
            emptyStr: "",
         )
      let e = "a".styles(style.0)
      #expect(r == e)
   }


   @Test(arguments: Self.colors)
   func `apply basic colors`(color: (BasicColor, TextColor)) {
      let r = "a"
         .styledStatus(
            nil,
            fg: color.1,
            bg: color.1,
            isVisible: true,
            emptyStr: "",
         )
      let e = "a".fg(color.0).bg(color.0)
      #expect(r == e)
   }


   @Test(arguments: [1, 200, 100, 255])
   func `apply extended color`(code: Int) {
      let r = "a"
         .styledStatus(
            nil,
            fg: .ext(code),
            bg: .ext(code),
            isVisible: true,
            emptyStr: "",
         )
      let e = "a".fg(code).bg(code)
      #expect(r == e)
   }


   @Test(
      arguments: [
         "#FFF",
         "#FF6B35",
         "#4ECDC4",
         "#45B7D1",
         "#96CEB4",
         "#FECA57",
      ]
   )
   func `apply hex color`(hex: String) {
      let r = "a"
         .styledStatus(
            nil,
            fg: .hex(hex),
            bg: .hex(hex),
            isVisible: true,
            emptyStr: "",
         )
      let e = "a".fg(.hex(hex)).bg(.hex(hex))
      #expect(r == e)
   }


   @Test(
      arguments: [
         (255, 107, 53),
         (78, 205, 196),
         (69, 183, 209),
         (150, 206, 180),
         (254, 202, 87),
      ]
   )
   func `apply RGB color`(rgb: (Int, Int, Int)) {
      let r = "a"
         .styledStatus(
            nil,
            fg: .rgb(rgb.0, rgb.1, rgb.2),
            bg: .rgb(rgb.0, rgb.1, rgb.2),
            isVisible: true,
            emptyStr: "",
         )
      let e = "a".fg(.rgb(rgb.0, rgb.1, rgb.2)).bg(.rgb(rgb.0, rgb.1, rgb.2))
      #expect(r == e)
   }


   @Test(
      arguments: [
         (15, 0.79, 1.0),
         (174, 0.62, 0.8),
         (198, 0.67, 0.82),
         (160, 0.27, 0.81),
         (42, 0.66, 1.0),
      ]
   )
   func `apply HSB color`(hsb: (Double, Double, Double)) {
      let r = "a"
         .styledStatus(
            nil,
            fg: .hsb(hsb.0, hsb.1, hsb.2),
            bg: .hsb(hsb.0, hsb.1, hsb.2),
            isVisible: true,
            emptyStr: "",
         )
      let e = "a"
         .fg(.hsb(hsb.0, hsb.1, hsb.2))
         .bg(.hsb(hsb.0, hsb.1, hsb.2))
      #expect(r == e)
   }


   @Test(arguments: [true, false])
   func `applying to empty string doesn't apply anything`(isVisible: Bool) {
      let r = ""
         .styledStatus(
            [.bold],
            fg: .green,
            bg: .brightRed,
            isVisible: isVisible,
            emptyStr: "",
         )

      #expect(r == "")
   }


   private static var colors: [(BasicColor, TextColor)] {
      BasicColor.allCases.map {
         let txtColor: TextColor =
            switch $0 {
            case .black: .black
            case .red: .red
            case .green: .green
            case .yellow: .yellow
            case .blue: .blue
            case .magenta: .magenta
            case .cyan: .cyan
            case .white: .white
            case .brightBlack: .brightBlack
            case .brightRed: .brightRed
            case .brightGreen: .brightGreen
            case .brightYellow: .brightYellow
            case .brightBlue: .brightBlue
            case .brightMagenta: .brightMagenta
            case .brightCyan: .brightCyan
            case .brightWhite: .brightWhite
            }

         return ($0, txtColor)
      }
   }


   private static var styles: [(Style, [TextStyle])] {
      Style.allCases.map {
         let txtStyle: TextStyle =
            switch $0 {
            case .bold: .bold
            case .faint: .faint
            case .italic: .italic
            case .underline: .underline
            case .blink: .blink
            case .fastBlink: .fastBlink
            case .reverse: .reverse
            case .erase: .erase
            case .strikethrough: .strikethrough
            case .fraktur: .fraktur
            case .doubleUnderline: .doubleUnderline
            }

         return ($0, [txtStyle])
      }
   }
}
