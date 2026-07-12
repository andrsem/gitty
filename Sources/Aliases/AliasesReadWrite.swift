// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Algorithms
package import Foundation
import SW40
import Shared

extension Aliases {
   package static func read(
      from data: () throws -> Data
   ) throws(AliasesError) -> Self {
      do {
         return try JSONDecoder.json5
            .decode([Alias].self, from: try data())
            .map { try $0.cleaned() }
            .uniqued()
            .sorted()
      } catch AliasError.invalidName {
         throw .invalidFormat(AliasError.invalidName.description)
      } catch AliasError.invalidCommand {
         throw .invalidFormat(AliasError.invalidCommand.description)
      } catch {
         throw .invalidFormat(error.decodingErrorDescription)
      }
   }
}



package enum AliasesError: Error, Equatable {
   case invalidFormat(String)
}



extension AliasesError: CustomStringConvertible {
   package var description: String {
      switch self {
      case let .invalidFormat(error):
         "Failed to read aliases JSON5 file. \(error)"
      }
   }
}
