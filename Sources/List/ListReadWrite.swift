// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package import Foundation
import SW40
import Shared

extension List {
   package static func write(
      _ list: List,
      toFile: (Data) throws -> Void,
   ) throws(ListError) {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [
         .sortedKeys, .prettyPrinted, .withoutEscapingSlashes,
      ]

      do {
         try list |> encoder.encode |> toFile
      } catch { throw .unableToSave }
   }


   package static func read(
      from data: () throws -> Data,
      isRepoValid: (String) -> Bool,
   ) throws(ListError) -> List {
      do {
         return try JSONDecoder()
            .decode(List.self, from: data())
            .cleaning(isPathValid: isRepoValid)
      } catch { throw .unableToRead(error.decodingErrorDescription) }
   }
}
