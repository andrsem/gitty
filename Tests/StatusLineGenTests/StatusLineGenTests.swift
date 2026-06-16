// SPDX-FileCopyrightText: © 2025 Andrii Sem
// SPDX-License-Identifier: MIT

import Diffy
import Foundation
import Layout
import Testing

@testable import StatusLineGen

extension Tag {
   @Tag
   static var statusLineGen: Self
}

@Suite(.tags(.statusLineGen))
struct `Status Line Gen Tests` {
   @Test(arguments: [OutputStyle.columnar, .linear])
   func `status line without components`(_ outputStyle: OutputStyle) {
      let result = generateStatusLine(
         for: URL(filePath: "myPath"),
         layout: layout(outputStyle),
         status: cleanStatus
      )

      expectMatch((line: "", sortID: ""), result)
   }
}
