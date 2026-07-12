// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package enum LayoutError: Error, Equatable {
   case doesNotExist(String)
   case failedToDecode(String)
}


extension LayoutError: CustomStringConvertible {
   package var description: String {
      switch self {
      case let .doesNotExist(layout):
         "'\(layout)' layout doesn't exist."
      case let .failedToDecode(error):
         "Failed to read layout JSON5 file. \(error)"
      }
   }
}
