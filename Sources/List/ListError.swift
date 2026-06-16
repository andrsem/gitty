// SPDX-FileCopyrightText: © 2024 Andrii Sem
// SPDX-License-Identifier: MIT

package enum ListError: Error, Equatable {
   case unableToSave
   case unableToRead(String)
}


extension ListError: CustomStringConvertible {
   package var description: String {
      switch self {
      case .unableToSave:
         "There was an error while saving the repos list to a file."

      case let .unableToRead(error):
         "Failed to read list JSON file. \(error)"
      }
   }
}
