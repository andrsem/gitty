// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package import Foundation
import Shared

extension Layout {
   package static func read(
      name: String,
      from data: () throws -> Data,
   ) throws(LayoutError) -> Layout {
      let _data: Data
      do { _data = try data() } catch { throw .doesNotExist(name) }
      do {
         return try JSONDecoder.json5.decode(Layout.self, from: _data)
      } catch {
         throw .failedToDecode(error.decodingErrorDescription)
      }
   }
}
