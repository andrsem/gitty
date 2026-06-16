// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT


package enum StatusError: Error, Equatable {
   case invalidRaw(String)
}

extension StatusError: CustomStringConvertible {
   package var description: String {
      switch self {
      case let .invalidRaw(error):
         error.isEmpty ? "Raw status is invalid." : error
      }
   }
}
