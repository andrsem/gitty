// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package typealias Tags = [String]


extension Tags {
   package static let reservedTag = "none"
}


extension String {
   var isTagValid: Bool {
      !(isEmpty || contains(where: \.isWhitespace) || self == Tags.reservedTag)
   }
}
