// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

package import Foundation

extension JSONDecoder {
   package static var json5: JSONDecoder {
      let decoder = JSONDecoder()
      decoder.allowsJSON5 = true
      return decoder
   }
}



extension DecodingError {
   var decodingErrorDescription: String {
      let context: DecodingError.Context? =
         switch self {
         case .typeMismatch(_, let context): context
         case .valueNotFound(_, let context): context
         case .keyNotFound(_, let context): context
         case .dataCorrupted(let context): context
         @unknown default: nil
         }

      let debugDescription = context?.debugDescription.appending(" ") ?? ""
      let description =
         context
         .flatMap { $0.underlyingError as? NSError }
         .flatMap { $0.userInfo[NSDebugDescriptionErrorKey] as? String }
         ?? ""

      return debugDescription + description
   }
}



extension Error {
   package var decodingErrorDescription: String {
      (self as? DecodingError)?.decodingErrorDescription ?? ""
   }
}
