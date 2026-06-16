// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import SW40
import Shared

package enum TextColor: Decodable, Equatable, Sendable {
   case black
   case red
   case green
   case yellow
   case blue
   case magenta
   case cyan
   case white
   case brightBlack
   case brightRed
   case brightGreen
   case brightYellow
   case brightBlue
   case brightMagenta
   case brightCyan
   case brightWhite
   case ext(Int)
   case hex(String)
   case rgb(Int, Int, Int)
   case hsb(Double, Double, Double)
}


extension TextColor: RawRepresentable {
   package typealias RawValue = String


   package init?(rawValue: RawValue) {
      func color(from raw: String) -> Self? {
         switch true {
         case raw.hasPrefix(Self.ext): Self.extColor(from: raw)
         case raw.hasPrefix(Self.rgb): Self.rgbColor(from: raw)
         case raw.hasPrefix(Self.hsb): Self.hsbColor(from: raw)
         case raw.hasPrefix(Self.hex): Self.hexColor(from: raw)
         default: Self.basicColor(from: raw)
         }
      }
      guard let color = color(from: rawValue) else { return nil }
      self = color
   }


   package var rawValue: RawValue {
      switch self {
      case .black: "black"
      case .red: "red"
      case .green: "green"
      case .yellow: "yellow"
      case .blue: "blue"
      case .magenta: "magenta"
      case .cyan: "cyan"
      case .white: "white"
      case .brightBlack: "brightBlack"
      case .brightRed: "brightRed"
      case .brightGreen: "brightGreen"
      case .brightYellow: "brightYellow"
      case .brightBlue: "brightBlue"
      case .brightMagenta: "brightMagenta"
      case .brightCyan: "brightCyan"
      case .brightWhite: "brightWhite"
      case let .ext(code): "\(Self.ext) \(code)"
      case let .hex(value): "\(Self.hex) \(value)"
      case let .rgb(r, g, b): "\(Self.rgb) \(r) \(g) \(b)"
      case let .hsb(h, s, b): "\(Self.hsb) \(h) \(s) \(b)"
      }
   }


   private static func extColor(from raw: RawValue) -> Self? {
      let extValue = raw.trimmingPrefix(Self.ext).trimmedWN
      guard
         let value = Int(extValue),
         0 ... 255 ~= value
      else { return nil }
      return .ext(value)
   }


   private static func rgbColor(from raw: RawValue) -> Self? {
      let components =
         raw
         .trimmingPrefix(Self.rgb)
         .split(separator: " ", omittingEmptySubsequences: true)
         .map(String.init)
         .compactMap(Int.init)

      guard
         let r = components[safe: 0],
         let g = components[safe: 1],
         let b = components[safe: 2],
         0 ... 255 ~= r,
         0 ... 255 ~= g,
         0 ... 255 ~= b
      else { return nil }
      return .rgb(r, g, b)
   }


   private static func hsbColor(from raw: RawValue) -> Self? {
      let components =
         raw
         .trimmingPrefix(Self.hsb)
         .split(separator: " ", omittingEmptySubsequences: true)
         .compactMap(Double.init)

      guard
         let h = components[safe: 0],
         let s = components[safe: 1],
         let b = components[safe: 2],
         0 ... 360 ~= h,
         0 ... 1 ~= s,
         0 ... 1 ~= b
      else { return nil }
      return .hsb(h, s, b)
   }


   private static func hexColor(from raw: RawValue) -> Self? {
      let hexValue = raw.trimmingPrefix(Self.hex).trimmedWN
      let count = hexValue.trimmingPrefix("#").count
      guard count == 3 || count == 6 else { return nil }
      return .hex(hexValue)
   }


   private static func basicColor(from raw: RawValue) -> Self? {
      switch raw {
      case "black": .black
      case "red": .red
      case "green": .green
      case "yellow": .yellow
      case "blue": .blue
      case "magenta": .magenta
      case "cyan": .cyan
      case "white": .white
      case "brightBlack": .brightBlack
      case "brightRed": .brightRed
      case "brightGreen": .brightGreen
      case "brightYellow": .brightYellow
      case "brightBlue": .brightBlue
      case "brightMagenta": .brightMagenta
      case "brightCyan": .brightCyan
      case "brightWhite": .brightWhite
      default: nil
      }
   }


   private static let rgb = "rgb"
   private static let hsb = "hsb"
   private static let hex = "hex"
   private static let ext = "ext"
}
