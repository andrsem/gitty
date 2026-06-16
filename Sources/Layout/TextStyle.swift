// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package enum TextStyle: String, Decodable, Sendable, CaseIterable {
   case bold
   case faint
   case italic
   case underline
   case blink
   case fastBlink
   case reverse
   case erase
   case strikethrough
   case fraktur
   case doubleUnderline
}
